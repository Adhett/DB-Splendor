
DROP FUNCTION getnumjugprt;
DELIMITER $$
CREATE FUNCTION getnumjugprt ( 
    _IDPartida INT UNSIGNED ) RETURNS TINYINT UNSIGNED
BEGIN
    DECLARE num TINYINT UNSIGNED;

    SELECT count(*) INTO num
    FROM Participantes
    WHERE IDPartida = _IDPartida;
    
    RETURN num ;
END$$
DELIMITER ;
-----------------------------
DROP FUNCTION GetCostCrtClr;
DELIMITER $$
CREATE FUNCTION GetCostCrtClr( 
    _IDCartas CHAR(12), _IDColor ENUM('red','green','blue','white','black') ) 
    RETURNS TINYINT UNSIGNED

BEGIN
    DECLARE cost TINYINT UNSIGNED default 0;

    SELECT Coste INTO cost
    FROM carcol
    WHERE IDCartas = _IDCartas
    AND IDColor = _IDColor;
    
    RETURN ifnull(cost,0);
END$$
DELIMITER ;

SELECT Coste 
FROM carcol
WHERE IDCartas = "0G1B2R2N"
AND IDColor =  "red";

select GetCostCrtClr ("0G1B2R2N" , "red");

----------------------------------------
DROP FUNCTION GetTotalGemasAcc;
DELIMITER $$
CREATE FUNCTION GetTotalGemasAcc( 
    _IDPartida  INT      UNSIGNED, 
    _IDJugador  TINYINT  UNSIGNED, 
    _Turno      INT      UNSIGNED) 
RETURNS TINYINT UNSIGNED
BEGIN
    DECLARE gemastotal TINYINT UNSIGNED default 0;

    SELECT sum(Total) INTO gemastotal
        from GemPos 
    WHERE IDPartida = _IDPartida AND IDJugador =_IDJugador;

    RETURN ifnull(gemastotal,0);

END$$
DELIMITER ;

select sum(total) from gempos;

//-----------------------------------------

-- Funcion para consultar la cantidad de cartas de un color por una accion jugador

DROP FUNCTION GetNumCartesClrAcc;
DELIMITER $$
CREATE FUNCTION GetNumCartesClrAcc( 
    _IDColor   ENUM('red','green','blue','white','black'), 
    _IDPartida INT UNSIGNED, 
    _IDJugador TINYINT UNSIGNED, 
    _Turno     INT UNSIGNED ) RETURNS TINYINT UNSIGNED
BEGIN
    DECLARE cartastotalcolor TINYINT UNSIGNED default 0;

    SELECT count(*) INTO cartastotalcolor 
        from cartasparticipant as cp
        inner join cartas as c on cp.IDCartas = c.IDCartas
    WHERE cp.IDPartida = _IDPartida AND cp.IDJugador =_IDJugador
    AND cp.Turno= _Turno AND c.IDColor =_IDColor
    AND Reservada=false;

    RETURN ifnull(cartastotalcolor,0);

END$$
DELIMITER ;
SELECT count(*) 
        from cartasparticipant as cp
        inner join cartas as c on cp.IDCartas = c.IDCartas
    WHERE cp.IDPartida = 1 AND cp.IDJugador =1 
    AND cp.Turno= 1 AND c.IDColor ="blue"
    AND Reservada=false;

select count(*) from gempos;

-------
ALTER TABLE Cartas
    MODIFY COLUMN img VARCHAR(128);

-------
-- creamos una accion de TK2 coger2--
SELECT `Turno`, `Tipo`, `IDPartida`, `IDJugador` FROM `acciones` WHERE 1
-- Select cartas del tablero en un turno a un jugador
SELECT `IDCartas`, `Turno`, `IDPartida`, `IDJugador` FROM `cartastablero` WHERE 1
--
Select getnumcartesclracc ("blue", 1, 1,1);
Select getnumcartesclracc ("green", 1, 1,1);
Select getnumcartesclracc ("red", 1, 1,1);

---------------creamos funcion del total del numero del color del numero de
DROP FUNCTION IF EXISTS GetNumGemasClrAcc;
DELIMITER $$
CREATE FUNCTION GetNumGemasClrAcc( 
    _IDColor   ENUM('red','green','blue','white','black', 'golden'), 
    _IDPartida INT UNSIGNED, 
    _IDJugador TINYINT UNSIGNED, 
    _Turno     INT UNSIGNED ) RETURNS TINYINT UNSIGNED
BEGIN
    DECLARE gemastotalcolor TINYINT UNSIGNED default 0;

    SELECT total INTO gemastotalcolor
        from gempos 
    WHERE IDPartida = _IDPartida AND IDJugador =_IDJugador 
    AND Turno= _Turno AND IDColor = _IDColor;

    RETURN ifnull(gemastotalcolor,0);
END$$
DELIMITER ;

Select GetNumGemasClrAcc ("blue", 1, 1,1);
Select GetNumGemasClrAcc ("black", 1, 1,1);
Select GetNumGemasClrAcc ("red", 1, 1,1,1);
Select GetNumGemasClrAcc ("green", 1, 1,1,1);
----------------------------------------
DROP FUNCTION IF EXISTS GetPowerClrAcc;
DELIMITER $$
CREATE FUNCTION GetPowerClrAcc(
        _IDColor    ENUM('red','green','blue','white','black', 'golden'),
        _IDPartida  INT UNSIGNED,
        _IDJugador  TINYINT UNSIGNED,
        _Turno      INT UNSIGNED) RETURNS TINYINT UNSIGNED
BEGIN
    DECLARE gemastotalcolor   TINYINT UNSIGNED DEFAULT 0;
    DECLARE cartastotalcolor  TINYINT UNSIGNED DEFAULT 0;
    
    SELECT getnumcartesclracc (_IDColor, _IDPartida, _IDJugador, _Turno) INTO cartastotalcolor;
    SELECT GetNumGemasClrAcc (_IDColor, _IDPartida, _IDJugador, _Turno) INTO gemastotalcolor;

    RETURN gemastotalcolor + cartastotalcolor;

END$$

DELIMITER ;

select GetPowerClrAcc ("blue", 1,1,1);

     --------------HAY QUE PROBARLAS A PARTIR DE AQUI-----------------------
------------------CREAMOS UN PROCEDURE DE CREAR PARTIDA-------------------------
CALL BorrarTodo(); CALL CrearPrt (1,1,2,3,NULL,10,10,15);
--------FUNCIONA, NO DA ERROR YA ESTA INSERTADA
    DROP PROCEDURE IF EXISTS CrearPrt;
    DELIMITER $$
    CREATE PROCEDURE CrearPrt(
        _IDPartida     INT UNSIGNED, 
        _IDJugador     TINYINT UNSIGNED,
        _IDJugador2    TINYINT UNSIGNED,
        _IDJugador3    TINYINT UNSIGNED,
        _IDJugador4    TINYINT UNSIGNED,
        _TiempoPartida TINYINT UNSIGNED,
        _TiempoMaximo  TINYINT UNSIGNED,
        _PuntosFinal   TINYINT UNSIGNED) 
    BEGIN
        DECLARE numJugadores TINYINT DEFAULT 2;
        DECLARE contador     TINYINT;               
        DECLARE unIDCarta    CHAR(12);              
        DECLARE unIDNoble    TINYINT UNSIGNED;
        DECLARE UltimoJug    TINYINT UNSIGNED ;      
        DECLARE cCrt1        CURSOR FOR     
                
            SELECT IDCartas  FROM Cartas
                WHERE Nivel = 1
                ORDER BY RAND()
                LIMIT 4;

        DECLARE cCrt2 CURSOR FOR
        SELECT IDCartas FROM Cartas
                WHERE Nivel = 2
                ORDER BY RAND()
                LIMIT 4;
        
        DECLARE cCrt3 CURSOR FOR
            SELECT IDCartas FROM Cartas
                WHERE Nivel = 3
                ORDER BY RAND()
                LIMIT 4;

        DECLARE cNbl CURSOR FOR
            SELECT IDNoble FROM nobles
                ORDER BY RAND();

        
        START TRANSACTION;

        INSERT INTO Partida (IDPartida, TiempoPartida,TiempoMax,PuntosFinal,TimepoTurno,Fecha)
            VALUES (_IDPartida,_TiempoPartida,_TiempoMaximo, SYSDATE(),_PuntosFinal, SYSDATE());


        
        INSERT INTO Participantes (IDPartida,IDJugador, Orden)
            VALUES (_IDPartida, _IDJugador, 1), (_IDPartida, _IDJugador2, 2);
            SET UltimoJug = _IDJugador2;
     
        
        IF _IDJugador3 IS NOT NULL THEN
            INSERT INTO Participantes (IDPartida, IDJugador, Orden)
                VALUES (_IDPartida, _IDJugador3, 3);
            SET numJugadores  = 3;  
            SET UltimoJug = _IDJugador3;

            IF _IDJugador4 IS NOT NULL THEN
                INSERT INTO Participantes (IDPartida, IDJugador, Orden)
                    VALUES (_IDPartida, _IDJugador4, 4);
                SET numJugadores = 4;
                SET UltimoJug = _IDJugador4;
            END IF;
        END IF;
        

        INSERT INTO Acciones (IDPartida, IDJugador,Turno, Tipo)
        SELECT _IDPartida, IDJugador, 0 , "PSS"
        FROM Participantes
        WHERE IDPartida = _IDPartida
        ORDER BY Orden;

        INSERT INTO gempos (Variacion,Total,IDColor,Turno,IDPartida,IDJugador)
        SELECT 0, 0, C.IDColor, 0, _IDPartida, P.IDJugador
        FROM Participantes as P, colores as C
        WHERE IDPartida = _IDPartida;

        OPEN cCrt1;
        SET contador = 0;
        WHILE contador < 4 DO      
            FETCH cCrt1 INTO unIDCarta;  
            SET contador = contador + 1;
            INSERT INTO CartasTablero (IDPartida, IDJugador, Turno, IDCartas)
                VALUES(_IDPartida, UltimoJug, 0, unIDCarta); 
        END WHILE;
        CLOSE cCrt1;
        OPEN cCrt2;
        SET contador = 0;
        WHILE contador < 4 DO      
            FETCH cCrt2 INTO unIDCarta;
            SET contador = contador + 1;
            INSERT INTO CartasTablero (IDPartida, IDJugador, Turno, IDCartas)
                VALUES(_IDPartida, UltimoJug, 0, unIDCarta); 
        END WHILE;
        CLOSE cCrt2;

        OPEN cCrt3;
        SET contador = 0;
        WHILE contador < 4 DO      
            FETCH cCrt3 INTO unIDCarta;
            SET contador = contador + 1;
            INSERT INTO CartasTablero (IDPartida, IDJugador, Turno, IDCartas)
                VALUES(_IDPartida, UltimoJug, 0, unIDCarta); 
        END WHILE;
        CLOSE cCrt3;

        OPEN cNbl;
        WHILE numJugadores >= 0 DO      
            FETCH cNbl INTO unIDNoble;  
            SET numJugadores = numJugadores - 1;
            INSERT INTO NoblesPartida (IDPartida, IDNoble)
                VALUES(_IDPartida, unIDNoble); 
        END WHILE;
        CLOSE cNbl;

        COMMIT;
    END$$
    DELIMITER ;
----------------------------
DROP FUNCTION IF EXISTS GetNumGemesClrEnJuego;
DELIMITER $$
CREATE FUNCTION GetNumGemesClrEnJuego( 
    _IDPartida  INT UNSIGNED, 
    _IDColor    ENUM ('red','green','blue','white','black', 'golden') )RETURNS TINYINT UNSIGNED
BEGIN
    DECLARE numJugadores TINYINT UNSIGNED;

    IF _IDColor = 'golden' THEN 
        RETURN 5;
    ELSE 
        SELECT getnumjugprt (_IDPartida) INTO numJugadores;
        IF numJugadores = 4 THEN 
            RETURN 7;
        ELSE 
            RETURN numJugadores +2;
        END IF;
    END IF;
END$$
DELIMITER ;
---------------------------------
--OBTENER ACCION ANTERIOR--NO DA ERROR, YA ESTA INTRODUCIDA.
---------------------------------
 
--Procedimiento para obtener la accion previa a una accion en la partida--
DROP PROCEDURE IF EXISTS GetAccionAnterior;
DELIMITER $$
/* Procedimiento para obtener la accion previa a una accion en la partida */
CREATE PROCEDURE GetAccionAnterior(
    IN  _IDPartida                INT UNSIGNED,
    IN  _IDJugadorActual          INT UNSIGNED,
    IN  _TurnoActual              SMALLINT UNSIGNED,
    OUT _IDJugadorAnterior        INT UNSIGNED,
    OUT _TurnoAnterior            SMALLINT UNSIGNED )
BEGIN
    DECLARE numJugPrt               TINYINT  UNSIGNED;
    DECLARE ordenJugadorActual      TINYINT;
    DECLARE ordrenJugadorAnterior   TINYINT;

    /* Averiguamos el orden del jugador que nos han pasado en cada turno */
    SELECT Orden INTO ordenJugadorActual
        FROM Participantes
        WHERE IDPartida = _IDPartida and IDJugador = _IDJugadorActual;
/* Necesitamos saber el número de jugadoras */
    SELECT GetNumJugPrt(_IDPartida) INTO numJugPrt;
/* Para averiguar el turno y el orden del jugador anterior... */

    IF _TurnoActual = 0 THEN
    /* La acción anterior a la de turno 0 siempre es ella misma: Turno 0, jugador 1er */
        SET _TurnoAnterior  = 0;
        SET ordrenJugadorAnterior = 1;
    ELSE
        IF ordenJugadorActual = 1 THEN
        /* Si el jugador de la acción es el primero,
        la acción anterior es la del turno -1... */
            SET _TurnoAnterior = _TurnoActual-1;

            IF _TurnoActual = 1 THEN
            /* La acción anterior a jugador 1er, turno 1 es jugador 1er turno 0 */
                SET ordrenJugadorAnterior = 1;
            ELSE
            /* La acción anterior a jugador 1er, turno X es jugador último turno X-1 */
                SET ordrenJugadorAnterior = numJugPrt;
            END IF;
        ELSE
        /* Si el jugador de la acción no es el primero, la acción anterior
        es la del jugador que tiene un orden-1 dentro del mismo turno */
            SET ordrenJugadorAnterior = ordenJugadorActual - 1;
            SET _TurnoAnterior = _TurnoActual;
        END IF;
    END IF;
/* Averiguamos el id del jugador anterior */
    SELECT IDJugador INTO _IDJugadorAnterior
        FROM Participantes
        WHERE IDPartida = _IDPartida AND Orden = ordrenJugadorAnterior;
END$$

DELIMITER ;

------------NO DA ERROR, ESTA INTRODUCIDA--
DROP PROCEDURE IF EXISTS GetAccionSiguiente;
DELIMITER $$
CREATE PROCEDURE GetAccionSiguiente(
    IN  _IDPartida              INT UNSIGNED,
    IN  _IDJugadorActual        INT UNSIGNED,
    IN  _TurnoActual            SMALLINT UNSIGNED,
    OUT _IDJugadorSiguiente     INT UNSIGNED,
    OUT _TurnoSiguiente         SMALLINT UNSIGNED )
BEGIN
    DECLARE numJugPrt             TINYINT  UNSIGNED;
    DECLARE ordenJugadorActual    TINYINT  UNSIGNED;
    DECLARE ordenJugadorSiguiente TINYINT  UNSIGNED;

    /* Averiguamos el orden del jugador que nos han pasado en cada turno */
    SELECT Orden INTO ordenJugadorActual
        FROM Participantes
        WHERE IDPartida = _IDPartida and IDJugador = _IDJugadorActual;

    /* Necesitamos saber el numero de jugadores */
    SELECT GetNumJugPrt(_IDPartida) INTO numJugPrt;

    /* Para averiguar el turno y el orden del siguiente jugador... */
    
   IF ordenJugadorActual = numJugPrt THEN
       /* Si la acción es del último jugador de la rueda, la siguiente acción es:
        primer jugador, turno +1 */
            SET ordenJugadorSiguiente = 1;
            SET _TurnoSiguiente = _TurnoActual +1;
    ELSE
        /* Si la acción no es del jugador en el lugar X de la rueda, la siguiente acción es:
        jugador del puesto X+1 y mismo turno */
            SET ordenJugadorSiguiente = ordenJugadorActual +1;
            SET _TurnoSiguiente = _TurnoActual;
    END IF;
    SELECT IDJugador INTO _IDJugadorSiguiente FROM Participantes
    WHERE IDPartida = _IDPartida AND orden = ordenJugadorSiguiente;  
END$$
DELIMITER ;
---------------------------------
--------------NO DA ERROR, ESTA INTRODUCIDA--
DROP PROCEDURE IF EXISTS GetUltimaAccionPrt;
DELIMITER $$
CREATE PROCEDURE GetUltimaAccionPrt(
    IN  _IDPartida        INT UNSIGNED,
    OUT _IDJugadorLast    INT UNSIGNED,
    OUT _TurnoLast        SMALLINT UNSIGNED )
BEGIN
    SELECT a.IDJugador, a.Turno INTO _IDJugadorLast, _TurnoLast
        FROM Acciones as a
        INNER JOIN Participantes as p
            ON a.IDJugador = p.IDJugador AND a.IDPartida = p.IDPartida
        WHERE a.IDPartida = _IDPartida
        ORDER BY a.Turno DESC, p.Orden DESC
        LIMIT 1;
END$$
DELIMITER;
----------------- INTRODUCIDA, NO DA ERROR----
CALL NuevaAccPass(1);

DROP PROCEDURE IF EXISTS NuevaAccPass;
DELIMITER $$
CREATE PROCEDURE NuevaAccPass(
    IN _IDPartida INT UNSIGNED
)
BEGIN
    DECLARE IDJugadorUlt INT UNSIGNED;
    DECLARE TurnoUlt     INT UNSIGNED;
    DECLARE IDJugadorSig INT UNSIGNED;
    DECLARE TurnoSig     INT UNSIGNED;

START TRANSACTION;

    CALL GetUltimaAccionPrt (_IDPartida, IDJugadorUlt, TurnoUlt);
    CALL GetAccionSiguiente (_IDPartida, IDJugadorUlt, TurnoUlt, IDJugadorSig, TurnoSig);

    INSERT INTO Acciones (IDPartida, IDJugador, Turno, Tipo)
    VALUES (_IDPartida, IDJugadorSig, TurnoSig, 'PSS');

    INSERT INTO CartasTablero (IDCartas, Turno, IDPartida, IDJugador)
    SELECT IDCartas, TurnoSig, _IDPartida, IDJugadorSig from cartastablero 
    WHERE IDPartida= _IDPartida AND Turno = TurnoUlt AND IDJugador= IDJugadorUlt;

    INSERT INTO gempos (Variacion, Total, IDColor, Turno, IDPartida, IDJugador)
    SELECT 0, Total, IDColor, TurnoSig, IDPartida, IDJugadorSig from gempos 
    WHERE IDPartida = _IDPartida AND IDJugador = IDJugadorSig AND Turno = TurnoSig -1;

COMMIT;
END $$
DELIMITER ;

-----------------
/* Procediment per enregistrar una acció "take2G" */
CALL NovaAccTake2G(1,"red");

DROP PROCEDURE IF EXISTS NovaAccTake2G;
DELIMITER $$
CREATE PROCEDURE NovaAccTake2G( 
    _IDPartida INT UNSIGNED, 
    _IDColor ENUM('red','green','blue','white','black')
     ) 
BEGIN
    DECLARE _IDJugador   INT UNSIGNED;
    DECLARE _NumGemas    INT UNSIGNED;
    DECLARE IDJugadorUlt INT UNSIGNED;
    DECLARE TurnoUlt     INT UNSIGNED;
    DECLARE IDJugadorSig INT UNSIGNED;
    DECLARE TurnoSig     INT UNSIGNED;


    CALL GetUltimaAccionPrt (_IDPartida, IDJugadorUlt, TurnoUlt);
    CALL GetAccionSiguiente (_IDPartida, IDJugadorUlt, TurnoUlt, IDJugadorSig, TurnoSig);
    
    /* Recopilar estado */
    SELECT GetTotalGemasAcc(_IDPartida, IDJugadorSig, TurnoSig -1) INTO _NumGemas;
    
    /* Si esta accion es posible */
    IF ( _NumGemas < 9) THEN
        /* crear accion */
        INSERT INTO acciones (IDPartida, Tipo, IDJugador, Turno) VALUES (_IDPartida, 'TK2', IDJugadorSig, TurnoSig);
        /* copiar cartas jugador accion anterior */
        INSERT INTO cartasparticipant(IDPartida, IDJugador, Turno, IDCartas, Reservada)
        SELECT IDPartida, IDJugadorSig, TurnoSig, IDCartas, Reservada
        FROM cartasparticipant 
        WHERE IDPartida = _IDPartida AND IDJugador = IDJugadorSig  AND Turno = TurnoSig -1;  
        /* copiar gemas accion anterior */
        INSERT INTO gempos (Variacion, Total, IDColor, Turno, IDPartida, IDJugador)
        SELECT 0, Total, IDColor, TurnoSig, IDPartida, IDJugadorSig 
        FROM gempos 
        WHERE IDPartida = _IDPartida AND IDJugador = IDJugadorSig AND Turno = TurnoSig -1;  
        /* sumar 2 al color de gema que quieres tomar */
        UPDATE gempos
        SET total = total + 2, Variacion = 2
        WHERE IDColor = _IDColor AND IDPartida = _IDPartida 
        AND IDJugador = IDJugadorSig AND Turno = TurnoSig;
        
        INSERT INTO CartasTablero (IDCartas, Turno, IDPartida, IDJugador)
        SELECT IDCartas, TurnoSig, _IDPartida, IDJugadorSig from cartastablero 
        WHERE IDPartida= _IDPartida AND Turno = TurnoUlt AND IDJugador= IDJugadorUlt;
    END IF;
END $$
DELIMITER ;
----------------------
/* Procediment per enregistrar una acció "take3G" */
CALL NovaAccTake3G(1,"black","green","blue");

DROP PROCEDURE IF EXISTS NovaAccTake3G;
DELIMITER $$
CREATE PROCEDURE NovaAccTake3G(
    _IDPartida INT UNSIGNED,
    _IDColor1 ENUM('red','green','blue','white','black'),
    _IDColor2 ENUM('red','green','blue','white','black'),
    _IDColor3 ENUM('red','green','blue','white','black')
)
BEGIN
    DECLARE NumGemas TINYINT UNSIGNED;
    DECLARE _IDJugador   INT UNSIGNED;
    DECLARE IDJugadorUlt INT UNSIGNED;
    DECLARE TurnoUlt     INT UNSIGNED;
    DECLARE IDJugadorSig INT UNSIGNED;
    DECLARE TurnoSig     INT UNSIGNED;

    CALL GetUltimaAccionPrt (_IDPartida, IDJugadorUlt, TurnoUlt);
    CALL GetAccionSiguiente (_IDPartida, IDJugadorUlt, TurnoUlt, IDJugadorSig, TurnoSig);
    SELECT GetTotalGemasAcc(_IDPartida, IDJugadorSig, TurnoSig -1) INTO NumGemas;
    /* Si la acción es posible */
    IF (NumGemas < 8) THEN
        /* Crear acción */
        INSERT INTO acciones (IDPartida, Tipo, IDJugador, Turno) 
        VALUES (_IDPartida, 'TK3', IDJugadorSig, TurnoSig);
        
        /* Copiar cartas jugador acción anterior */
        INSERT INTO cartasparticipant(IDPartida, IDJugador, Turno, IDCartas, Reservada)
        SELECT IDPartida, IDJugadorSig, TurnoSig, IDCartas, Reservada
        FROM cartasparticipant 
        WHERE IDPartida = _IDPartida AND IDJugador = IDJugadorSig  AND Turno = TurnoSig -1;  

        
        /* Copiar gemas acción anterior */
        INSERT INTO gempos (Variacion, Total, IDColor, Turno, IDPartida, IDJugador)
        SELECT 0, Total, IDColor, TurnoSig, IDPartida, IDJugadorSig 
        FROM gempos 
        WHERE IDPartida = _IDPartida AND IDJugador = IDJugadorSig AND Turno = TurnoSig -1; 

        /* Sumar 1 a cada color de gema que se desea tomar */
        UPDATE gempos
        SET total = total +1 , Variacion = 1
        WHERE IDColor IN (_IDColor1, _IDColor2, _IDColor3)  AND IDPartida = _IDPartida 
        AND IDJugador = IDJugadorSig AND Turno = TurnoSig;
    
        INSERT INTO CartasTablero (IDCartas, Turno, IDPartida, IDJugador)
        SELECT IDCartas, TurnoSig, _IDPartida, IDJugadorSig from cartastablero 
        WHERE IDPartida= _IDPartida AND Turno = TurnoUlt AND IDJugador= IDJugadorUlt;
    END IF;
END $$
DELIMITER ;


----------------------
/* Funció per demanar el nombre de punts associats a una acció-jugador d'una partida */
FUNCTION GetNumPuntsAcc(
    _prtId TINYINT UNSIGNED,
    _jugId INT UNSIGNED,
    _torn SMALLINT UNSIGNED
) RETURNS TINYINT UNSIGNED
----------------------
/* Procediment per capturar tots els nobles que corresponguin en una acció en funció de les cartes que es poseeixen */
DROP PROCEDURE IF EXISTS CapturaNblAcc;
DELIMITER $$
CREATE PROCEDURE CapturaNblAcc(
    _IDPartida TINYINT UNSIGNED,
    _IDJugador INT UNSIGNED,
    _Turno     SMALLINT UNSIGNED
)
BEGIN
    DECLARE numCartasRed    TINYINT UNSIGNED DEFAULT 0;
    DECLARE numCartasGreen  TINYINT UNSIGNED DEFAULT 0;
    DECLARE numCartasBlue   TINYINT UNSIGNED DEFAULT 0;
    DECLARE numCartasBlack  TINYINT UNSIGNED DEFAULT 0;
    DECLARE numCartasWhite  TINYINT UNSIGNED DEFAULT 0;
    DECLARE final           TINYINT UNSIGNED DEFAULT 0;
    DECLARE IDNbl           TINYINT UNSIGNED;

    DECLARE costNobleRed    TINYINT UNSIGNED DEFAULT 0;
    DECLARE costNobleGreen  TINYINT UNSIGNED DEFAULT 0;
    DECLARE costNobleBlue   TINYINT UNSIGNED DEFAULT 0;
    DECLARE costNobleBlack  TINYINT UNSIGNED DEFAULT 0;
    DECLARE costNobleWhite  TINYINT UNSIGNED DEFAULT 0;

    DECLARE cIDNoble CURSOR FOR
        SELECT IDNoble 
            FROM noblespartida
            WHERE IDPartida = _IDPartida AND IDPartidaAcc IS NULL;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET final = -1;
    
    SELECT GetNumCartesClrAcc("red", _IDPartida, _IDJugador, _Turno)   INTO numCartasRed;
    SELECT GetNumCartesClrAcc("green", _IDPartida, _IDJugador, _Turno) INTO numCartasGreen;
    SELECT GetNumCartesClrAcc("blue", _IDPartida, _IDJugador, _Turno)  INTO numCartasBlue;
    SELECT GetNumCartesClrAcc("black", _IDPartida, _IDJugador, _Turno) INTO numCartasBlack;
    SELECT GetNumCartesClrAcc("white", _IDPartida, _IDJugador, _Turno) INTO numCartasWhite;

    OPEN cIDNoble;

    getNoble: LOOP

        SET costNobleRed = 0;
        SET costNobleGreen = 0;
        SET costNobleBlue = 0;
        SET costNobleBlack = 0;
        SET costNobleWhite = 0;

        SET final = 0;

        FETCH cIDNoble INTO IDNbl;

        IF final = -1 THEN
            LEAVE getNoble;
        END IF;

        SELECT Coste INTO costNobleRed
            FROM cosnob
            WHERE IDNoble = IDNbl AND IDColor = "red";
        SELECT Coste INTO costNobleGreen
            FROM cosnob
            WHERE IDNoble = IDNbl AND IDColor = "green";
        SELECT Coste INTO costNobleBlue
            FROM cosnob
            WHERE IDNoble = IDNbl AND IDColor = "blue";
        SELECT Coste INTO costNobleBlack
            FROM cosnob
            WHERE IDNoble = IDNbl AND IDColor = "black";
        SELECT Coste INTO costNobleWhite
            FROM cosnob
            WHERE IDNoble = IDNbl AND IDColor = "white";
        IF numCartasRed >= costNobleRed AND numCartasGreen >= costNobleGreen AND numCartasBlue >= costNobleBlue
        AND numCartasBlack >= costNobleBlack AND numCartasWhite >= costNobleWhite THEN

            UPDATE noblespartida SET IDPartidaAcc = _IDPartida, IDJugador = _IDJugador, Turno = _Turno 
            WHERE IDNoble = IDNbl;
        END IF;
    END LOOP getNoble;
    CLOSE cIDNoble;
END$$

---------------------------------
----NO DA ERROR, ESTA INTRODUCIDA--
---------------------------------
DROP FUNCTION IF EXISTS GetNewCartaNivelAcc;
DELIMITER $$
CREATE FUNCTION GetNewCartaNivelAcc(
_Nivel      TINYINT UNSIGNED,
_IDPartida  INT UNSIGNED,
_IDJugador  TINYINT UNSIGNED,
_Turno      INT UNSIGNED
) RETURNS VARCHAR(16)
BEGIN
DECLARE IDNuevaCrt VARCHAR(16) DEFAULT NULL; 

SELECT IDCartas INTO IDNuevaCrt
FROM Cartas
WHERE Nivel = _Nivel AND
IDCartas NOT IN (
SELECT IDCartas
FROM CartasTablero
WHERE IDPartida = _IDPartida
UNION SELECT IDCartas from cartasparticipant
WHERE IDPartida = _IDPartida)
ORDER BY RAND()
LIMIT 1;
RETURN IDNuevaCrt;
END $$
DELIMITER ;

/* Afirma o nega si una carta és comprable per un determinat jugador-acció i permet saber si es troba al 'T'auler o a la ma del jugador reservada 'MR'*/
DROP PROCEDURE IF EXISTS CartaComprableAcc;
DELIMITER $$
CREATE PROCEDURE CartaComprableAcc(
    _IDCartas       VARCHAR(16),
    _IDPartida      TINYINT UNSIGNED,
    _IDJugador      INT UNSIGNED,
    _Turno          SMALLINT UNSIGNED,
    OUT _comprable  BOOLEAN,
    OUT _TM         ENUM ('T', 'MR')
)
BEGIN
    DECLARE CartaEnTablero      BOOLEAN DEFAULT FALSE;
    DECLARE CartaEstaReservada  BOOLEAN DEFAULT FALSE;
    DECLARE CosteRed     TINYINT UNSIGNED;
    DECLARE CosteBlue    TINYINT UNSIGNED;
    DECLARE CosteGreen   TINYINT UNSIGNED;
    DECLARE CosteBlack   TINYINT UNSIGNED;
    DECLARE CosteWhite   TINYINT UNSIGNED;

    DECLARE done BOOLEAN DEFAULT FALSE;

    CALL    GetNumCartesClrAcc (_IDColor,_IDPartida,_IDJugador,_Turno)   TINYINT UNSIGNED;
    CALL    GetNumGemasClrAcc  (_IDColor,_IDPartida,_IDJugador,_Turno)   TINYINT UNSIGNED;
    SELECT  GetCostCrtClr      (_IDCartas, "red")   INTO CosteRed;
    SELECT  GetCostCrtClr      (_IDCartas, "blue")  INTO CosteBlue;
    SELECT  GetCostCrtClr      (_IDCartas, "green") INTO CosteGreen;
    SELECT  GetCostCrtClr      (_IDCartas, "black") INTO CosteBlack;
    SELECT  GetCostCrtClr      (_IDCartas, "white") INTO CosteWhite;

    DECLARE curCoste CURSOR FOR 
        SELECT Coste, IDColor 
        FROM carcol 
        WHERE IDCartas = _IDCartas;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    START TRANSACTION;

    SET _comprable = FALSE;
    IF (
        SELECT IDCartas
        FROM cartastablero 
        WHERE IDCartas = _IDCartas
            AND IDPartida = _IDPartida
            AND IDJugador = _IDJugador
            AND Turno = _Turno
        ) IS NOT NULL THEN

        SET CartaEnTablero = TRUE;
        SET _TM = "T";

    ELSEIF (
            SELECT IDCartas 
            FROM cartasparticipant
            WHERE IDCartas = _IDCartas
                AND IDPartida = _IDPartida
                AND IDJugador = _IDJugador
                AND Turno = _Turno
                AND Reservada = TRUE
            ) IS NOT NULL THEN
        SET CartaEstaReservada = TRUE;
        SET _TM = "MR";
    END IF;

    IF cartaEstaEnTablero OR cartaEstaReservada THEN
        SET _comprable = TRUE;

        OPEN curCoste;
        _loop: LOOP

        	FETCH curCoste INTO cantidadCosteColor, nombreCosteColor;
        	IF done THEN
        		LEAVE _loop;
        	END IF;

        	SELECT GetTotalGemasUnColorAcc(_IDPartida, IDColor, _IDJugador, _Turno) INTO totalGemasUnColorAccJug;

        	IF totalGemasUnColorAccJug < cantidadCosteColor THEN
        		SET _comprable = FALSE;
        		LEAVE _loop;
            END IF;
        END LOOP;
    END IF;

    COMMIT;
END$$
DELIMITER ;


/* Ajusta les gemes en possessió del jugador acció per comprar una carta */
PROCEDURE PayGemesCrtAcc(
    _crtId VARCHAR(16),
    _prtId INT UNSIGNED,
    _jugId INT UNSIGNED,
    _torn SMALLINT UNSIGNED
)

/* Procediment per enregistrar una acció "buy" */
PROCEDURE NovaAccBuy(
    _prtId INT UNSIGNED,
    _crtId VARCHAR(16)
)

/* Procediment per enregistrar una acció "buyHolded" */
PROCEDURE NovaAccBuyHolded(
    _prtId INT UNSIGNED,
    _crtId VARCHAR(16)
)

/* Procediment per enregistrar una acció "hold" */
CALL CrearPrt (1,1,2,3,NULL,10,10,15);
CALL NovaAccHold(1,"0G2B2R");

    DROP PROCEDURE IF EXISTS NovaAccHold;
    DELIMITER $$
    CREATE PROCEDURE NovaAccHold(
        _IDPartida  INT UNSIGNED,
        _IDCartas   VARCHAR(16)
    )
    BEGIN
        DECLARE IDJugadorUlt        INT UNSIGNED;
        DECLARE TurnoUlt            SMALLINT UNSIGNED;
        DECLARE IDJugadorSig        INT UNSIGNED;
        DECLARE TurnoSig            SMALLINT UNSIGNED;
        DECLARE NuevaIDCarta        VARCHAR(16);
        DECLARE GemasDoradasMesa    TINYINT DEFAULT 0;
        DECLARE CartasHoldeadas     TINYINT DEFAULT 0;
        DECLARE CartaEstaEnTablero  BOOLEAN DEFAULT FALSE;
        DECLARE NivelCartaHoldeada  TINYINT UNSIGNED;
        
        START TRANSACTION;

        CALL GetUltimaAccionPrt(_IDPartida, IDJugadorUlt, TurnoUlt);
        CALL GetAccionSiguiente(_IDPartida, IDJugadorUlt, TurnoUlt, IDJugadorSig, TurnoSig);

        SELECT count(*) INTO CartasHoldeadas
        FROM cartasparticipant
        WHERE Reservada = 1 
            AND IDPartida = _IDPartida
            AND Turno = TurnoSig -1
            AND IDJugador = IDJugadorSig; 

        SELECT count(*) INTO CartaEstaEnTablero
        FROM cartastablero
        WHERE IDCartas = _IDCartas
            AND IDPartida = _IDPartida
            AND IDJugador = IDJugadorUlt
            AND Turno = TurnoUlt;
        
        SELECT GetNumGemasTablerorAccClr(_IDPartida,TurnoUlt,'golden') INTO GemasDoradasMesa;


        SELECT Nivel INTO NivelCartaHoldeada
        FROM cartas
        WHERE IDCartas = _IDCartas;

        SELECT GetNewCartaNivelAcc(NivelCartaHoldeada, _IDPartida,IDJugadorUlt,TurnoUlt) INTO NuevaIDCarta;


        IF CartasHoldeadas < 3 AND GemasDoradasMesa > 0 AND CartaEstaEnTablero = TRUE THEN
            
            INSERT INTO acciones (IDPartida, Tipo, IDJugador, Turno) 
            VALUES (_IDPartida, 'RES', IDJugadorSig, TurnoSig);

            INSERT INTO cartastablero
            SELECT IDCartas, TurnoSig,_IDPartida,IDJugadorSig
            FROM cartastablero
            WHERE Turno = TurnoUlt
                AND IDJugador = IDJugadorUlt
                AND IDPartida = _IDPartida
                AND IDCartas <> _IDCartas;

            IF NuevaIDCarta IS NOT NULL THEN
                INSERT INTO cartastablero
                SELECT NuevaIDCarta,TurnoSig,_IDPartida,IDJugadorSig;
            END IF;
            
            INSERT INTO gempos (Variacion, Total, IDColor, Turno, IDPartida, IDJugador)
            SELECT 0, Total, IDColor, TurnoSig, _IDPartida, IDJugadorSig 
            FROM gempos 
            WHERE IDPartida = _IDPartida AND IDJugador = IDJugadorSig AND Turno = TurnoSig -1
            AND IDColor <> "golden"; 

            INSERT INTO gempos
            SELECT 1, Total + 1, 'golden', TurnoSig, _IDPartida, IDJugadorSig
            FROM gempos;

            INSERT INTO cartasparticipant(IDPartida, IDJugador, Turno, IDCartas, Reservada)
            SELECT _IDPartida, IDJugadorSig, TurnoSig, IDCartas, Reservada
            FROM cartasparticipant 
            WHERE IDPartida = _IDPartida AND IDJugador = IDJugadorSig  AND Turno = TurnoSig -1;  

            INSERT INTO cartasparticipant
            SELECT 1,_IDCartas,TurnoSig,_IDPartida, IDJugadorSig;
    
        END IF;

        COMMIT;
    END$$
    DELIMITER ;
/* Procediment per enregistrar una acció "blindHold" que permet fer una reserva d'una carta d'un nivell sense saber quina ens tocarà (a cegues) */
CALL NuevaAccBlindHold(1,1);

DROP PROCEDURE IF EXISTS NuevaAccBlindHold;
DELIMITER $$
CREATE PROCEDURE NuevaAccBlindHold(
    _IDPartida INT UNSIGNED, 
    _Nivel TINYINT UNSIGNED)
BEGIN
    DECLARE IDJugadorUlt INT UNSIGNED;
    DECLARE TurnoUlt     INT UNSIGNED;
    DECLARE IDJugadorSig INT UNSIGNED;
    DECLARE TurnoSig     INT UNSIGNED;
    DECLARE GemasDoradasMesa TINYINT DEFAULT 0;
    DECLARE CartasHoldeadas  TINYINT DEFAULT 0;
    DECLARE NuevaIDCarta VARCHAR(16);
    
    START TRANSACTION;

    CALL GetUltimaAccionPrt(_IDPartida, IDJugadorUlt, TurnoUlt);
    CALL GetAccionSiguiente(_IDPartida, IDJugadorUlt, TurnoUlt, IDJugadorSig, TurnoSig);

    SELECT COUNT(*) INTO CartasHoldeadas
    FROM cartasparticipant 
    WHERE Reservada = 1 
        AND IDPartida = _IDPartida
        AND Turno = TurnoSig - 1
        AND IDJugador = IDJugadorSig; 

    SELECT GetNumGemasTablerorAccClr(_IDPartida,TurnoUlt,'golden') INTO GemasDoradasMesa;
    SELECT GetNewCartaNivelAcc(NuevaIDCarta, _IDPartida,IDJugadorSig,TurnoSig) INTO NuevaIDCarta;
    
    IF CartasHoldeadas < 3 AND GemasDoradasMesa > 0 AND NuevaIDCarta IS NOT NULL THEN
    
        INSERT INTO acciones (IDPartida, Tipo, IDJugador, Turno) 
        VALUES (_IDPartida,'RES', IDJugadorSig, TurnoSig);

        INSERT INTO cartastablero
        SELECT IDCartas, TurnoSig, _IDPartida, _IDJugadorSig
        FROM CartasTablero
        WHERE Turno = TurnoUlt
            AND IDJugador = IDJugadorUlt
            AND IDPartida = _IDPartida;

        INSERT INTO gempos
        SELECT 0, Total, IDColor, TurnoSig, IDPartida, IDJugadorSig
        FROM gempos
        WHERE IDJugador = IDJugadorSig
            AND Turno = TurnoSig - 1
            AND IDPartida = _IDPartida
            AND IDColor <> 'golden';

        INSERT INTO gempos
        SELECT 1, 1, 'golden', TurnoSig, IDPartida, IDJugadorSig;
        
        INSERT INTO cartasparticipant
        SELECT Reservada,IDCartas, TurnoSig, _IDPartida, IDJugadorSig
        FROM cartasparticipant
        WHERE IDJugador = IDJugadorSig
            AND Turno = TurnoSig - 1
            AND IDPartida = _IDPartida;

        INSERT INTO cartasparticipant
        SELECT 1,NuevaIDCarta, TurnoSig, _IDPartida, IDJugadorSig;
    END IF;
    COMMIT;
END$$
DELIMITER ;

/* Funció que permet saber quantes gemes disponibles al tauler de cada color, en un moment-acció del joc incloent el daurat. Pot ser un torn incomplet */
DROP FUNCTION IF EXISTS GetNumGemasTablerorAccClr;
DELIMITER $$
CREATE FUNCTION GetNumGemasTablerorAccClr(
    _IDPartida TINYINT  UNSIGNED,
    _Turno     SMALLINT UNSIGNED,
    _IDColor   ENUM('red','green','blue','white','black', 'golden')
) RETURNS TINYINT UNSIGNED

BEGIN
    DECLARE numtotal     TINYINT UNSIGNED;
    DECLARE numcogidas   TINYINT UNSIGNED DEFAULT 0;

    SELECT GetNumGemesClrEnJuego (_IDPartida, _IDColor) INTO numtotal;

    SELECT SUM(Total) INTO numcogidas
    FROM gempos
    WHERE IDColor = _IDColor AND IDPartida = _IDPartida AND
        ( Turno = _Turno
        OR
        ( Turno = _Turno - 1
        AND IDJugador NOT IN (
            SELECT IDJugador FROM acciones
            WHERE IDPartida = _IDPartida AND Turno = _Turno
            )
        )
    );
    RETURN numtotal - numcogidas;
END $$
DELIMITER ;
--------------------------------------------
---CARGAR IMAGENES EN LA BASE DE DATOS---
/*
$folder = "C:\Users\toni\Docs\Nivel"
$Nivel = "1"

Get-ChildItem -Path $folder -Filter "*.jpg" | ForEach-Object {
    $file = $_.Name
    $IDCartas = $file.Substring(0, $file.Length - 4)

    $FileContent = [System.IO.File]::ReadAllBytes($folder + "\" + $file)
    $query = "UPDATE Cartas SET img = 0x$([System.BitConverter]::ToString($FileContent).Replace('-','')) WHERE IDCartas ='"$IDCartas';"
    $query 


    # ./UpdateImgCartas.ps1 |Out-File updates.sql -Enconding ASCII

}

*/
--------------------------------------

DROP PROCEDURE BorrarTodo;
DELIMITER $$
CREATE PROCEDURE BorrarTodo()
BEGIN
    DELETE FROM cartastablero;
    DELETE FROM cartasparticipant;
    DELETE FROM noblespartida;
    DELETE FROM gempos;
    DELETE FROM acciones;
    DELETE FROM participantes;
    DELETE FROM partida;

END$$
DELIMITER ;




