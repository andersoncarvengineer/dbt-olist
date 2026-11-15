with

customers as (
    select * from {{ ref('stg_olist__customers') }}
),

orders as (
    select * from {{ ref('stg_olist__orders') }}
),

-- endereço do pedido mais recente de cada cliente
customer_addresses as (

    select
        customers.unique_id,
        customers.zip_code_prefix,
        customers.city,
        customers.state,
        row_number() over (
            partition by customers.unique_id
            order by orders.purchased_at desc
        ) as address_rank
    from customers
    inner join orders using (customer_id)

),

latest_address as (
    select
        * from customer_addresses where address_rank = 1
),

customer_orders as (

    select
        customer_unique_id,
        min(purchased_at)                                  as first_order_at,
        max(purchased_at)                                  as last_order_at,
        count(*) filter (where not is_canceled)            as orders_count,
        sum(revenue_amount)                                as lifetime_revenue
    from {{ ref('fct_orders') }}
    group by 1

),

final as (

    select
        latest_address.unique_id                           as customer_unique_id,
        latest_address.zip_code_prefix,
        latest_address.city,
        latest_address.state,
        customer_orders.first_order_at,
        customer_orders.last_order_at,
        customer_orders.orders_count,
        customer_orders.lifetime_revenue,
        coalesce(customer_orders.orders_count, 0) > 1      as is_repeat_buyer
    from latest_address
    left join customer_orders
        on latest_address.unique_id = customer_orders.customer_unique_id

)

select * from final