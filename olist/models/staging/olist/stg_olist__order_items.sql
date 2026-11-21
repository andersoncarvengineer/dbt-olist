with

source as (

    select * from {{ source('olist','order_items') }}
),

renamed as (
    
select 
    order_id, 
    cast(order_item_id as int) as order_item_id,
    product_id,
    seller_id,
    cast(shipping_limit_date as timestamp with time zone) as shipping_limit_at,
    {{ to_reais('price') }}         as price,
    {{ to_reais('freight_value') }} as freight_value,
    _loaded_at
from source

)

select * from renamed

