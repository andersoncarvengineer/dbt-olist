with

source as (

    select * from {{ source('olist', 'orders') }}

),

renamed as (

    select
        order_id,
        customer_id,
        order_status as status,

        cast(order_purchase_timestamp as timestamp with time zone) as purchased_at,
        cast(order_approved_at as timestamp with time zone) as approved_at,
        cast(order_delivered_carrier_date as timestamp with time zone) as delivered_to_carrier_at,
        cast(order_delivered_customer_date as timestamp with time zone) as delivered_to_customer_at,
        cast(order_estimated_delivery_date as date) as estimated_delivery_date,

        cast(_loaded_at as timestamp with time zone) as _loaded_at

    from source

)

select * from renamed