with

source as (

    select * from {{ source('olist','order_reviews') }}
),

renamed as (

    select 

        review_id,
        order_id,
        cast(review_score as int) as review_score,
        review_comment_title,
        review_comment_message,
        cast(review_creation_date as date) as created_date,
        cast(review_answer_timestamp as timestamp with time zone) as answered_at,
        _loaded_at
    from source
)

select * from renamed