with customers as (
    select * from {{ ref('stg_customers') }}
),

final as (
    select
        customer_id,
        first_name,
        last_name,
        -- ここに将来的に注文回数などのロジックを追加できます
        current_timestamp() as loaded_at
    from customers
)

select * from final
