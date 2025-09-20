use employees;

-- 1. Conteo General
SELECT COUNT(*)
FROM employees;

-- 2. Salarios Extremos
SELECT MAX(salary), MIN(salary)
FROM salaries;

-- 3. Promedio Salarial
SELECT AVG(salary)
FROM salaries;

-- 4. Agrupación por Género
SELECT gender, COUNT(*)
FROM employees
GROUP BY gender;

-- 5. Conteo de Cargos
SELECT title, COUNT(DISTINCT emp_no) cantidad
FROM titles
GROUP BY title
ORDER BY cantidad DESC;

-- 6. Filtro de Grupos con HAVING (> 75000 empleados)
SELECT title, COUNT(DISTINCT emp_no) cantidad
FROM titles
GROUP BY title
HAVING cantidad > 75000
ORDER BY cantidad DESC;

-- 7. Agrupación Múltiple: Cantidad por género y cargo
SELECT title, gender, COUNT(DISTINCT e.emp_no) AS cantidad_empleados
FROM titles t
JOIN employees e ON t.emp_no = e.emp_no
GROUP BY title, gender
ORDER BY title, gender;

-- 8. Nombres de Departamentos actuales de empleados
SELECT e.emp_no, e.first_name, d.dept_name
FROM employees e
JOIN dept_emp de ON e.emp_no = de.emp_no
JOIN departments d ON de.dept_no = d.dept_no
WHERE de.to_date = '9999-01-01';

-- 9. Empleados en departamento Marketing
SELECT e.first_name, e.last_name
FROM employees e
JOIN dept_emp de ON e.emp_no = de.emp_no
JOIN departments d ON de.dept_no = d.dept_no
WHERE d.dept_name = 'Marketing' AND de.to_date = '9999-01-01';

-- 10. Gerentes actuales con nombre completo y departamento
SELECT e.emp_no, CONCAT(e.first_name, ' ', e.last_name) AS nombre_completo, d.dept_name
FROM employees e
JOIN dept_manager dm ON e.emp_no = dm.emp_no
JOIN departments d ON dm.dept_no = d.dept_no
WHERE dm.to_date = '9999-01-01';

-- 11. Salario promedio actual por departamento
SELECT d.dept_name, AVG(s.salary) AS salario_promedio
FROM departments d
JOIN dept_emp de ON d.dept_no = de.dept_no
JOIN salaries s ON de.emp_no = s.emp_no
WHERE de.to_date = '9999-01-01' AND s.to_date = '9999-01-01'
GROUP BY d.dept_name;

-- 12. Historial de cargos del empleado 10006
SELECT title, from_date, to_date
FROM titles
WHERE emp_no = 10006
ORDER BY from_date;

-- 13. Departamentos sin empleados (LEFT JOIN)
SELECT d.dept_name
FROM departments d
LEFT JOIN dept_emp de ON d.dept_no = de.dept_no AND de.to_date = '9999-01-01'
WHERE de.emp_no IS NULL;

-- 14. Salario actual de todos los empleados (nombre, apellido, salario)
SELECT e.first_name, e.last_name, s.salary
FROM employees e
JOIN salaries s ON e.emp_no = s.emp_no
WHERE s.to_date = '9999-01-01';

-- 15. Empleados con salario actual mayor al promedio
SELECT e.emp_no, e.first_name, e.last_name, s.salary
FROM employees e
JOIN salaries s ON e.emp_no = s.emp_no
WHERE s.to_date = '9999-01-01' AND s.salary > (
    SELECT AVG(salary) FROM salaries WHERE to_date = '9999-01-01'
);

-- 16. Nombres de gerentes (subconsulta con IN)
SELECT first_name, last_name
FROM employees
WHERE emp_no IN (SELECT DISTINCT emp_no FROM dept_manager);

-- 17. Empleados que nunca han sido gerentes (NOT IN)
SELECT first_name, last_name
FROM employees
WHERE emp_no NOT IN (SELECT DISTINCT emp_no FROM dept_manager);

-- 18. Último empleado contratado
SELECT first_name, last_name, hire_date
FROM employees
ORDER BY hire_date DESC
LIMIT 1;

-- 19. Jefes que han dirigido Development
SELECT e.first_name, e.last_name
FROM employees e
JOIN dept_manager dm ON e.emp_no = dm.emp_no
JOIN departments d ON dm.dept_no = d.dept_no
WHERE d.dept_name = 'Development';

-- 20. Empleados con salario máximo registrado
SELECT e.emp_no, e.first_name, e.last_name, s.salary
FROM employees e
JOIN salaries s ON e.emp_no = s.emp_no
WHERE s.salary = (SELECT MAX(salary) FROM salaries);

-- 21. Nombres completos de primeros 100 empleados
SELECT CONCAT(first_name, ' ', last_name) AS nombre_completo
FROM employees
LIMIT 100;

-- 22. Antigüedad en años de cada empleado
SELECT emp_no, TIMESTAMPDIFF(YEAR, hire_date, CURDATE()) AS antiguedad_anios
FROM employees;

-- 23. Categorizar salarios actuales con CASE
SELECT e.emp_no, s.salary,
  CASE
    WHEN s.salary < 50000 THEN 'Bajo'
    WHEN s.salary BETWEEN 50000 AND 90000 THEN 'Medio'
    ELSE 'Alto'
  END AS categoria_salarial
FROM employees e
JOIN salaries s ON e.emp_no = s.emp_no
WHERE s.to_date = '9999-01-01';

-- 24. Conteo de empleados contratados por mes (independientemente del año)
SELECT MONTH(hire_date) AS mes_contratacion, COUNT(*) AS cantidad
FROM employees
GROUP BY mes_contratacion
ORDER BY mes_contratacion;

-- 25. Iniciales de empleados
SELECT CONCAT(LEFT(first_name, 1), '.', LEFT(last_name, 1), '.') AS iniciales
FROM employees;

-- 26. Departamento con mejor salario promedio actual
SELECT d.dept_name, AVG(s.salary) AS salario_promedio
FROM departments d
JOIN dept_emp de ON d.dept_no = de.dept_no
JOIN salaries s ON de.emp_no = s.emp_no
WHERE de.to_date = '9999-01-01' AND s.to_date = '9999-01-01'
GROUP BY d.dept_name
ORDER BY salario_promedio DESC
LIMIT 1;

-- 27. Gerente con más tiempo en el cargo
SELECT e.first_name, e.last_name, DATEDIFF(COALESCE(dm.to_date, CURDATE()), dm.from_date) AS dias_en_cargo
FROM dept_manager dm
JOIN employees e ON dm.emp_no = e.emp_no
ORDER BY dias_en_cargo DESC
LIMIT 1;

-- 28. Incremento salarial del empleado 10001 (primer salario vs actual)
SELECT
  s1.salary AS primer_salario,
  s2.salary AS salario_actual,
  s2.salary - s1.salary AS incremento
FROM salaries s1
JOIN salaries s2 ON s1.emp_no = s2.emp_no
WHERE s1.emp_no = 10001
AND s1.from_date = (SELECT MIN(from_date) FROM salaries WHERE emp_no = 10001)
AND s2.to_date = '9999-01-01';

-- 29. Pares de empleados contratados el mismo día
SELECT e1.emp_no AS emp_no_1, e1.first_name AS nombre_1, e1.hire_date,
       e2.emp_no AS emp_no_2, e2.first_name AS nombre_2
FROM employees e1
JOIN employees e2 ON e1.hire_date = e2.hire_date AND e1.emp_no < e2.emp_no
ORDER BY e1.hire_date;

-- 30. Ingeniero senior mejor pagado (Senior Engineer con salario actual más alto)
SELECT e.first_name, e.last_name, s.salary
FROM employees e
JOIN titles t ON e.emp_no = t.emp_no
JOIN salaries s ON e.emp_no = s.emp_no
WHERE t.title = 'Senior Engineer'
AND s.to_date = '9999-01-01'
ORDER BY s.salary DESC
LIMIT 1;
