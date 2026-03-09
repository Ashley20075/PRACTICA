-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 09-03-2026 a las 17:17:56
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `practica 1`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_listaAutores` ()   BEGIN

SELECT *
FROM tbl_autor;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_tipoAutor` (IN `variable` VARCHAR(20))   BEGIN

SELECT 
A.AUT_CODIGO,
A.AUT_APELLIDO,
T.TIPOAUTOR
FROM tbl_autor A
INNER JOIN tbl_tipoautores T
ON A.AUT_CODIGO = T.COPIAAUTOR
WHERE T.TIPOAUTOR = variable;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_libro` (IN `c1_isbn` BIGINT, IN `c2_titulo` VARCHAR(255), IN `c3_genero` VARCHAR(20), IN `c4_paginas` INT, IN `c5_dias` TINYINT)   BEGIN

INSERT INTO tbl_libro
VALUES(c1_isbn,c2_titulo,c3_genero,c4_paginas,c5_dias);

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_actualizar_socio` (IN `p_numero` INT, IN `p_direccion` VARCHAR(255), IN `p_telefono` VARCHAR(10))   BEGIN
    UPDATE tbl_socio
    SET 
        SOC_DIRECCION = p_direccion,
        SOC_TELEFONO = p_telefono
    WHERE SOC_NUMERO = p_numero;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_buscar_libro_nombre` (IN `p_nombre` VARCHAR(255))   BEGIN
    SELECT *
    FROM tbl_libro
    WHERE LIB_TITULO LIKE CONCAT('%', p_nombre, '%');
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_eliminar_libro` (IN `p_isbn` BIGINT)   BEGIN
    DECLARE existe INT;

    SELECT COUNT(*) INTO existe
    FROM tbl_prestamo
    WHERE LIB_COPIAISBN = p_isbn;

    IF existe = 0 THEN
        DELETE FROM tbl_libro
        WHERE LIB_ISBN = p_isbn;
    ELSE
        SELECT 'No se puede eliminar, tiene prestamos' AS mensaje;
    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insertar_socio` (IN `p_numero` INT, IN `p_nombre` VARCHAR(45), IN `p_apellido` VARCHAR(45), IN `p_direccion` VARCHAR(255), IN `p_telefono` VARCHAR(10))   BEGIN
    INSERT INTO tbl_socio
    VALUES (p_numero, p_nombre, p_apellido, p_direccion, p_telefono);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_libros_en_prestamo` ()   BEGIN
    SELECT
        L.LIB_TITULO,
        S.SOC_NOMBRE,
        P.PRES_FECHAPRESTAMO,
        P.PRES_FECHADEVOLUCION
    FROM tbl_prestamo P
    INNER JOIN tbl_libro L 
        ON P.LIB_COPIAISBN = L.LIB_ISBN
    INNER JOIN tbl_socio S 
        ON P.SOC_COPIANUMERO = S.SOC_NUMERO;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_socios_con_prestamos` ()   BEGIN
    SELECT 
        S.SOC_NUMERO,
        S.SOC_NOMBRE, 
        P.PRES_ID,
        P.PRES_FECHAPRESTAMO,
        P.PRES_FECHADEVOLUCION
    FROM tbl_socio S
    LEFT JOIN tbl_prestamo P 
        ON S.SOC_NUMERO = P.SOC_COPIANUMERO;
END$$

--
-- Funciones
--
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_dias_prestamo` (`p_isbn` BIGINT) RETURNS INT(11) DETERMINISTIC BEGIN
    DECLARE dias INT;

    SELECT DATEDIFF(
        IFNULL(PRES_FECHADEVOLUCION, CURDATE()),
        PRES_FECHAPRESTAMO
    )
    INTO dias
    FROM tbl_prestamo
    WHERE LIB_COPIAISBN = p_isbn
    LIMIT 1;

    RETURN dias;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `fn_total_socios` () RETURNS INT(11) DETERMINISTIC BEGIN
    DECLARE total INT;

    SELECT COUNT(*) INTO total
    FROM tbl_socio;

    RETURN total;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `aprendiz`
--

CREATE TABLE `aprendiz` (
  `id_aprendiz` int(11) NOT NULL,
  `apr_nombre` varchar(50) NOT NULL,
  `apr_apellido` varchar(50) NOT NULL,
  `apr_correo` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `aprendiz`
--

INSERT INTO `aprendiz` (`id_aprendiz`, `apr_nombre`, `apr_apellido`, `apr_correo`) VALUES
(1, 'Juan', 'Pérez', 'juan.perez@email.com'),
(2, 'María', 'Gómez', 'maria.gomez@email.com'),
(3, 'Carlos', 'López', 'carlos.lopez@email.com');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `aprendizidx`
--

CREATE TABLE `aprendizidx` (
  `id_aprendiz` varchar(11) NOT NULL,
  `apr_nombre` varchar(45) NOT NULL,
  `apr_apellido` varchar(45) NOT NULL,
  `apr_correo` varchar(45) NOT NULL,
  `apr_ubicacion` varchar(10) NOT NULL DEFAULT 'Bogotá'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auditoria_autor`
--

CREATE TABLE `auditoria_autor` (
  `id` int(11) NOT NULL,
  `accion` varchar(20) DEFAULT NULL,
  `autor_codigo` int(11) DEFAULT NULL,
  `fecha` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auditoria_libro`
--

CREATE TABLE `auditoria_libro` (
  `id` int(11) NOT NULL,
  `accion` varchar(20) DEFAULT NULL,
  `libro_isbn` bigint(20) DEFAULT NULL,
  `fecha` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auditoria_socio`
--

CREATE TABLE `auditoria_socio` (
  `id` int(11) NOT NULL,
  `accion` varchar(20) DEFAULT NULL,
  `socio_numero` int(11) DEFAULT NULL,
  `fecha` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `audi_socio`
--

CREATE TABLE `audi_socio` (
  `id_audi` int(10) NOT NULL,
  `socNumero_audi` int(11) DEFAULT NULL,
  `socNombre_anterior` varchar(45) DEFAULT NULL,
  `socApellido_anterior` varchar(45) DEFAULT NULL,
  `socDireccion_anterior` varchar(255) DEFAULT NULL,
  `socTelefono_anterior` varchar(10) DEFAULT NULL,
  `socNombre_nuevo` varchar(45) DEFAULT NULL,
  `socApellido_nuevo` varchar(45) DEFAULT NULL,
  `socDireccion_nuevo` varchar(255) DEFAULT NULL,
  `socTelefono_nuevo` varchar(10) DEFAULT NULL,
  `audi_fechaModificacion` datetime DEFAULT NULL,
  `audi_usuario` varchar(10) DEFAULT NULL,
  `audi_accion` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `audi_socio`
--

INSERT INTO `audi_socio` (`id_audi`, `socNumero_audi`, `socNombre_anterior`, `socApellido_anterior`, `socDireccion_anterior`, `socTelefono_anterior`, `socNombre_nuevo`, `socApellido_nuevo`, `socDireccion_nuevo`, `socTelefono_nuevo`, `audi_fechaModificacion`, `audi_usuario`, `audi_accion`) VALUES
(1, 1, 'Ana', 'Ruiz', 'Calle Primavera 123, Ciudad Jardín, Barcelona', '9123456780', 'Ana', 'Ruiz', 'Calle Primavera 123, Ciudad Jardín, Barcelona', '600123456', '2026-03-05 07:18:41', 'root@local', 'Actualización'),
(2, 10, 'Andrea', 'García', 'Calle del Sol 432, La Colina, Zaragoza', '1112345678', 'Andrea', 'García', 'Calle 25 #18-30', '3114567890', '2026-03-05 11:27:06', 'root@local', 'Actualización');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `posiciones`
--

CREATE TABLE `posiciones` (
  `id` int(11) NOT NULL,
  `grupo` char(10) NOT NULL,
  `pais` varchar(45) NOT NULL,
  `jugados` int(11) NOT NULL,
  `ganados` int(11) NOT NULL,
  `empatados` int(11) NOT NULL,
  `perdidos` int(11) NOT NULL,
  `puntos` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_autor`
--

CREATE TABLE `tbl_autor` (
  `AUT_CODIGO` int(11) NOT NULL,
  `AUT_APELLIDO` varchar(45) NOT NULL,
  `AUT_NACIMIENTO` date NOT NULL,
  `AUT_MUERTE` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `tbl_autor`
--

INSERT INTO `tbl_autor` (`AUT_CODIGO`, `AUT_APELLIDO`, `AUT_NACIMIENTO`, `AUT_MUERTE`) VALUES
(98, 'Smith', '1974-12-21', '2018-07-21'),
(123, 'Taylor', '1980-04-15', '0000-00-00'),
(234, 'Medina', '1977-06-21', '2005-09-12'),
(345, 'Wilson', '1975-08-29', '0000-00-00'),
(432, 'Miller', '1981-10-26', '0000-00-00'),
(456, 'García', '1978-09-27', '2021-12-09'),
(567, 'Davis', '1983-03-04', '2010-03-28'),
(678, 'Silva', '1986-02-02', '0000-00-00'),
(765, 'López', '1976-07-08', '2020-05-15'),
(789, 'Rodríguez', '1985-12-10', '0000-00-00'),
(890, 'Brown', '1982-11-17', '0000-00-00'),
(901, 'Soto', '1979-05-13', '2015-11-05');

--
-- Disparadores `tbl_autor`
--
DELIMITER $$
CREATE TRIGGER `trg_delete_autor` AFTER DELETE ON `tbl_autor` FOR EACH ROW BEGIN

INSERT INTO auditoria_autor(accion, autor_codigo)
VALUES('DELETE', OLD.AUT_CODIGO);

END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_update_autor` AFTER UPDATE ON `tbl_autor` FOR EACH ROW BEGIN

INSERT INTO auditoria_autor(accion, autor_codigo)
VALUES('UPDATE', OLD.AUT_CODIGO);

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_libro`
--

CREATE TABLE `tbl_libro` (
  `LIB_ISBN` bigint(20) NOT NULL,
  `LIB_TITULO` varchar(255) NOT NULL,
  `LIB_GENERO` varchar(20) NOT NULL,
  `LIB_NUMEROPAGINAS` int(11) NOT NULL,
  `LIB_DIASPRESTAMO` tinyint(4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `tbl_libro`
--

INSERT INTO `tbl_libro` (`LIB_ISBN`, `LIB_TITULO`, `LIB_GENERO`, `LIB_NUMEROPAGINAS`, `LIB_DIASPRESTAMO`) VALUES
(1234567890, 'El Sueño de los Susurros', 'Novela', 275, 7),
(1357924680, 'El Jardín de las Mariposas Perdidas', 'Novela', 536, 7),
(2468135790, 'La Melodía de la Oscuridad', 'Romance', 189, 7),
(2718281828, 'El Bosque de los Suspiros', 'Novela', 387, 2),
(3141592653, 'El Secreto de las Estrellas Olvidadas', 'Misterio', 203, 7),
(5555555555, 'La Última Llave del Destino', 'Cuento', 503, 7),
(7777777777, 'El Misterio de la Luna Plateada', 'Misterio', 422, 7),
(8642097531, 'El Reloj de Arena Infinito', 'Novela', 321, 7),
(8888888888, 'La Ciudad de los Susurros', 'Misterio', 274, 1),
(9517530862, 'Las Crónicas del Eco Silencioso', 'Fantasia', 448, 7),
(9876543210, 'El Laberinto de los Recuerdos', 'Cuento', 412, 7),
(9999999999, 'El Enigma de los Espejos Rotos', 'Romance', 156, 7);

--
-- Disparadores `tbl_libro`
--
DELIMITER $$
CREATE TRIGGER `trg_delete_libro` AFTER DELETE ON `tbl_libro` FOR EACH ROW BEGIN

INSERT INTO auditoria_libro(accion, libro_isbn)
VALUES('DELETE', OLD.LIB_ISBN);

END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_insert_libro` AFTER INSERT ON `tbl_libro` FOR EACH ROW BEGIN

INSERT INTO auditoria_libro(accion, libro_isbn)
VALUES('INSERT', NEW.LIB_ISBN);

END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_update_libro` AFTER UPDATE ON `tbl_libro` FOR EACH ROW BEGIN

INSERT INTO auditoria_libro(accion, libro_isbn)
VALUES('UPDATE', OLD.LIB_ISBN);

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_prestamo`
--

CREATE TABLE `tbl_prestamo` (
  `PRES_ID` varchar(20) NOT NULL,
  `PRES_FECHAPRESTAMO` date NOT NULL,
  `PRES_FECHADEVOLUCION` date NOT NULL,
  `SOC_COPIANUMERO` int(11) NOT NULL,
  `LIB_COPIAISBN` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `tbl_prestamo`
--

INSERT INTO `tbl_prestamo` (`PRES_ID`, `PRES_FECHAPRESTAMO`, `PRES_FECHADEVOLUCION`, `SOC_COPIANUMERO`, `LIB_COPIAISBN`) VALUES
('pres1', '2023-01-15', '2023-01-20', 1, 1234567890),
('pres2', '2023-02-03', '2023-02-04', 2, 9999999999),
('pres3', '2023-04-09', '2023-04-11', 6, 2718281828),
('pres4', '2023-06-14', '2023-06-15', 9, 8888888888),
('pres5', '2023-07-02', '2023-07-09', 10, 5555555555),
('pres6', '2023-08-19', '2023-08-26', 12, 5555555555),
('pres7', '2023-10-24', '2023-10-27', 3, 1357924680),
('pres8', '2023-11-11', '2023-11-12', 4, 9999999999);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_socio`
--

CREATE TABLE `tbl_socio` (
  `SOC_NUMERO` int(11) NOT NULL,
  `SOC_NOMBRE` varchar(45) NOT NULL,
  `SOC_APELLIDO` varchar(45) NOT NULL,
  `SOC_DIRECCION` varchar(255) NOT NULL,
  `SOC_TELEFONO` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `tbl_socio`
--

INSERT INTO `tbl_socio` (`SOC_NUMERO`, `SOC_NOMBRE`, `SOC_APELLIDO`, `SOC_DIRECCION`, `SOC_TELEFONO`) VALUES
(1, 'Ana', 'Ruiz', 'Calle Primavera 123, Ciudad Jardín, Barcelona', '600123456'),
(2, 'Andrés Felipe', 'Galindo Luna', 'Avenida del Sol 456, Pueblo Nuevo, Madrid ', '2123456789'),
(3, 'Juan ', 'González', 'Calle Principal 789, Villa Flores, Valencia', '2012345678'),
(4, 'Maria', 'Rodriguéz', 'Carrera del Río 321, El Pueblo, Sevilla', '3012345678'),
(5, 'Pedro', 'Martinéz', 'Calle del Bosque 654, Los Pinos, Málaga', '1234567812'),
(6, 'Ana', 'Lopéz', 'Avenida Central 987, Villa Hermosa, Bilbao ', '6123456781'),
(7, 'Carlos', 'Sánchez', 'Calle de la Luna 234, El Prado, Alicante', '1123456781'),
(8, 'Laura', 'Ramírez', 'Carrera del Mar 567, Playa Azul, Palma de Mallorca ', '1312345678'),
(9, 'Luis', 'Hernandéz', 'Avenida de la Montaña 890, Monte Verde, Granada', '6101234567'),
(10, 'Andrea', 'García', 'Calle 25 #18-30', '3114567890'),
(11, 'Alejandro', 'Torres', 'Carrera del Oeste 765, Ciudad Nueva, Murcia', '4951234567'),
(12, 'Sofia', 'Morales', 'Avenida del Mar 098, Costa Brava, Gijón', '5512345678'),
(13, 'Ashley', 'Perdomo', 'Calle 6f sur #8-26 este', '3137744561');

--
-- Disparadores `tbl_socio`
--
DELIMITER $$
CREATE TRIGGER `socios_before_update` BEFORE UPDATE ON `tbl_socio` FOR EACH ROW INSERT INTO audi_socio(
    socNumero_audi,
    socNombre_anterior,
    socApellido_anterior,
    socDireccion_anterior,
    socTelefono_anterior,
    socNombre_nuevo,
    socApellido_nuevo,
    socDireccion_nuevo,
    socTelefono_nuevo,
    audi_fechaModificacion,
    audi_usuario,
    audi_accion)
VALUES(
    new.soc_numero,
    old.soc_nombre,
    old.soc_apellido,
    old.soc_direccion,
    old.soc_telefono,
    new.soc_nombre,
    new.soc_apellido,
    new.soc_direccion,
    new.soc_telefono,
    NOW(),
    CURRENT_USER(),
    'Actualización')
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_delete_socio` AFTER DELETE ON `tbl_socio` FOR EACH ROW BEGIN

INSERT INTO auditoria_socio(accion, socio_numero)
VALUES('DELETE', OLD.SOC_NUMERO);

END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_update_socio` AFTER UPDATE ON `tbl_socio` FOR EACH ROW BEGIN

INSERT INTO auditoria_socio(accion, socio_numero)
VALUES('UPDATE', OLD.SOC_NUMERO);

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_tipoautores`
--

CREATE TABLE `tbl_tipoautores` (
  `COPIAISBN` bigint(20) NOT NULL,
  `COPIA_AUTOR` int(11) NOT NULL,
  `TIPO_AUTOR` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `tbl_tipoautores`
--

INSERT INTO `tbl_tipoautores` (`COPIAISBN`, `COPIA_AUTOR`, `TIPO_AUTOR`) VALUES
(1357924680, 123, 'Traductor'),
(1234567890, 123, 'Autor'),
(1234567890, 456, 'Coautor'),
(2718281828, 789, 'Traductor'),
(8888888888, 234, 'Autor'),
(2468135790, 234, 'Autor'),
(9876543210, 567, 'Autor'),
(1234567890, 890, 'Autor'),
(8642097531, 345, 'Autor'),
(8888888888, 345, 'Coautor'),
(5555555555, 678, 'Autor'),
(3141592653, 901, 'Autor'),
(9517530862, 432, 'Autor'),
(7777777777, 765, 'Autor'),
(9999999999, 98, 'Autor');

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_libros_autores`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_libros_autores` (
`LIB_TITULO` varchar(255)
,`AUT_APELLIDO` varchar(45)
,`TIPO_AUTOR` varchar(20)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_prestamos`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_prestamos` (
`PRES_ID` varchar(20)
,`LIB_TITULO` varchar(255)
,`SOC_NOMBRE` varchar(45)
,`PRES_FECHAPRESTAMO` date
,`PRES_FECHADEVOLUCION` date
);

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_libros_autores`
--
DROP TABLE IF EXISTS `vista_libros_autores`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_libros_autores`  AS SELECT `l`.`LIB_TITULO` AS `LIB_TITULO`, `a`.`AUT_APELLIDO` AS `AUT_APELLIDO`, `t`.`TIPO_AUTOR` AS `TIPO_AUTOR` FROM ((`tbl_libro` `l` join `tbl_tipoautores` `t` on(`l`.`LIB_ISBN` = `t`.`COPIAISBN`)) join `tbl_autor` `a` on(`t`.`COPIA_AUTOR` = `a`.`AUT_CODIGO`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_prestamos`
--
DROP TABLE IF EXISTS `vista_prestamos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_prestamos`  AS SELECT `p`.`PRES_ID` AS `PRES_ID`, `l`.`LIB_TITULO` AS `LIB_TITULO`, `s`.`SOC_NOMBRE` AS `SOC_NOMBRE`, `p`.`PRES_FECHAPRESTAMO` AS `PRES_FECHAPRESTAMO`, `p`.`PRES_FECHADEVOLUCION` AS `PRES_FECHADEVOLUCION` FROM ((`tbl_prestamo` `p` join `tbl_libro` `l` on(`p`.`LIB_COPIAISBN` = `l`.`LIB_ISBN`)) join `tbl_socio` `s` on(`p`.`SOC_COPIANUMERO` = `s`.`SOC_NUMERO`)) ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `aprendiz`
--
ALTER TABLE `aprendiz`
  ADD PRIMARY KEY (`id_aprendiz`);

--
-- Indices de la tabla `aprendizidx`
--
ALTER TABLE `aprendizidx`
  ADD PRIMARY KEY (`id_aprendiz`),
  ADD UNIQUE KEY `apr_correo` (`apr_correo`),
  ADD KEY `apr_nombre` (`apr_nombre`);

--
-- Indices de la tabla `auditoria_autor`
--
ALTER TABLE `auditoria_autor`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `auditoria_libro`
--
ALTER TABLE `auditoria_libro`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `auditoria_socio`
--
ALTER TABLE `auditoria_socio`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `audi_socio`
--
ALTER TABLE `audi_socio`
  ADD PRIMARY KEY (`id_audi`);

--
-- Indices de la tabla `posiciones`
--
ALTER TABLE `posiciones`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `idx_pais` (`pais`),
  ADD KEY `idx_grupo` (`grupo`);

--
-- Indices de la tabla `tbl_autor`
--
ALTER TABLE `tbl_autor`
  ADD PRIMARY KEY (`AUT_CODIGO`);

--
-- Indices de la tabla `tbl_libro`
--
ALTER TABLE `tbl_libro`
  ADD PRIMARY KEY (`LIB_ISBN`),
  ADD KEY `idx_lib_titulo` (`LIB_TITULO`);

--
-- Indices de la tabla `tbl_prestamo`
--
ALTER TABLE `tbl_prestamo`
  ADD PRIMARY KEY (`PRES_ID`),
  ADD KEY `SOC_COPIANUMERO` (`SOC_COPIANUMERO`),
  ADD KEY `LIB_COPIAISBN` (`LIB_COPIAISBN`);

--
-- Indices de la tabla `tbl_socio`
--
ALTER TABLE `tbl_socio`
  ADD PRIMARY KEY (`SOC_NUMERO`);

--
-- Indices de la tabla `tbl_tipoautores`
--
ALTER TABLE `tbl_tipoautores`
  ADD KEY `COPIAISBN` (`COPIAISBN`),
  ADD KEY `COPIA_AUTOR` (`COPIA_AUTOR`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `aprendiz`
--
ALTER TABLE `aprendiz`
  MODIFY `id_aprendiz` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `auditoria_autor`
--
ALTER TABLE `auditoria_autor`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `auditoria_libro`
--
ALTER TABLE `auditoria_libro`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `auditoria_socio`
--
ALTER TABLE `auditoria_socio`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `audi_socio`
--
ALTER TABLE `audi_socio`
  MODIFY `id_audi` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `posiciones`
--
ALTER TABLE `posiciones`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `tbl_prestamo`
--
ALTER TABLE `tbl_prestamo`
  ADD CONSTRAINT `tbl_prestamo_ibfk_1` FOREIGN KEY (`SOC_COPIANUMERO`) REFERENCES `tbl_socio` (`SOC_NUMERO`),
  ADD CONSTRAINT `tbl_prestamo_ibfk_2` FOREIGN KEY (`LIB_COPIAISBN`) REFERENCES `tbl_libro` (`LIB_ISBN`);

--
-- Filtros para la tabla `tbl_tipoautores`
--
ALTER TABLE `tbl_tipoautores`
  ADD CONSTRAINT `tbl_tipoautores_ibfk_1` FOREIGN KEY (`COPIAISBN`) REFERENCES `tbl_libro` (`LIB_ISBN`),
  ADD CONSTRAINT `tbl_tipoautores_ibfk_2` FOREIGN KEY (`COPIA_AUTOR`) REFERENCES `tbl_autor` (`AUT_CODIGO`);

DELIMITER $$
--
-- Eventos
--
CREATE DEFINER=`root`@`localhost` EVENT `anual_eliminar_prestamos` ON SCHEDULE EVERY 1 YEAR STARTS '2026-03-09 09:37:13' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN 
DELETE FROM tbl_prestamo
WHERE PRES_FECHADEVOLUCION <= NOW() - INTERVAL 1 YEAR;

END$$

CREATE DEFINER=`root`@`localhost` EVENT `eliminar_prestamos` ON SCHEDULE EVERY 1 YEAR STARTS '2026-01-01 00:00:00' ENDS '2030-01-01 00:00:00' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN

DELETE FROM tbl_prestamo
WHERE PRES_FECHADEVOLUCION < CURDATE() - INTERVAL 1 YEAR;

END$$

DELIMITER ;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
