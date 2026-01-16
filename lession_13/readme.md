### Написать запрос суммы очков с группировкой и сортировкой по годам
```
SELECT year_game, sum(points) AS point_sum 
FROM statistic 
GROUP BY year_game 
ORDER BY year_game;
```

### Написать cte показывающее тоже самое

```
WITH point_sum_cte AS ( 
    SELECT year_game,  sum(points) AS point_sum 
    FROM statistic 
    GROUP BY year_game 
    ORDER BY year_game
    ) 
SELECT * FROM point_sum_cte;
```

```
WITH point_sum_cte AS ( 
    SELECT year_game,  sum(points) AS point_sum 
    FROM statistic 
    GROUP BY year_game 
    ORDER BY year_game
    ) 
SELECT * FROM point_sum_cte WHERE year_game = '2020';
```

### Используя функцию LAG вывести кол-во очков по всем игрокам за текущий код и за предыдущий.

```
SELECT *, 
lag(points,1) OVER (PARTITION BY player_name ORDER BY year_game) as previous_points 
FROM statistic 
WHERE year_game IN (2020,2019) 
ORDER BY player_name, year_game DESC;
```