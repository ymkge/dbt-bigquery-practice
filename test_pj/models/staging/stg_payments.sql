with payments as (
    select
        id as payment_id,
        order_id,
        payment_method,
        -- amount はセント単位なので 100 で割る
        amount / 100 as amount
    from {{ source('jaffle_shop', 'raw_payments') }}
)

select * from payments
