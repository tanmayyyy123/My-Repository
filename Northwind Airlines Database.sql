-- Q1: How many tickets are there without boarding pass ?
SELECT 
    COUNT(*) 
FROM 
    tickets AS tkt
LEFT JOIN 
    boarding_passes AS pass
ON 
    tkt.ticket_no = pass.ticket_no
WHERE 
    pass.flight_id IS NULL
    OR pass.boarding_no IS NULL
    OR pass.seat_no IS NULL;


-- Q2: Represent the "book_date" column in "yyyy-mm-dd" format using Bookings table.
SELECT 
    book_ref,
    TO_CHAR(book_date, 'YYYY-MM-DD') AS book_date,
    total_amount
FROM 
    bookings;


-- Q3: Identify the most popular product in each store based on quantity sold.
SELECT 
    store_name,
    product_name,
    quantity_sold
FROM (
    SELECT 
        s.store_name,
        p.product_name,
        SUM(oi.quantity) AS quantity_sold,
        RANK() OVER (
            PARTITION BY s.store_name
            ORDER BY SUM(oi.quantity) DESC
        ) AS rnk
    FROM 
        stores AS s
    JOIN 
        orders AS o ON s.store_id = o.store_id
    JOIN 
        order_items AS oi ON o.order_id = oi.order_id
    JOIN 
        products AS p ON oi.product_id = p.product_id
    GROUP BY 
        s.store_name, p.product_name
) ranked
WHERE 
    rnk = 1;


-- Q4: The management team is interested in a detailed comparison of sales performance
-- across all stores on a quarterly basis. Your objective is to calculate total sales for each
-- quarter and then rank the stores based on these sales figures. This analysis will help to
-- identify top-performing stores and those that may require strategic adjustments.
WITH QuarterlySales AS (
    SELECT 
        TO_CHAR(o.order_date, 'YYYY-"Q"Q') AS year_quarter,
        s.store_name,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_sales
    FROM 
        stores AS s
    JOIN 
        orders AS o ON s.store_id = o.store_id
    JOIN 
        order_items AS oi ON o.order_id = oi.order_id
    GROUP BY 
        year_quarter,
        s.store_name
)
SELECT 
    year_quarter,
    store_name,
    total_sales,
    RANK() OVER (
        PARTITION BY year_quarter
        ORDER BY total_sales DESC
    ) AS performance_rank
FROM 
    QuarterlySales
ORDER BY 
    year_quarter,
    performance_rank;


-- Q5: Rank airports based on the number of flights departing from them.
SELECT 
    a.airport_name AS departure_airport,
    COUNT(*) AS total_flights,
    RANK() OVER (
        ORDER BY COUNT(*) DESC
    ) AS airport_rank
FROM 
    flights AS f
JOIN 
    airports AS a ON f.departure_airport = a.airport_code
GROUP BY 
    a.airport_name
ORDER BY 
    airport_rank;
