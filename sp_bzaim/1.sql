-- Создаю временню таблицу. Куда через цикл буду заполнять данные
CREATE GLOBAL TEMPORARY TABLE WG_BZAIM
(
  KOD_T          VARCHAR2(3 BYTE),
  NAIM_T         VARCHAR2(60 BYTE),
  KOD_U          NUMBER(2),
  NAIM_U         VARCHAR2(60 BYTE),
  DOLG_NACH      NUMBER,
  NACH_TEK       NUMBER,
  DOLG_NA_KONEC  NUMBER,
  OPL            NUMBER,
  PERES          NUMBER,
  KOD_RAION      CHAR(3 BYTE),
  NAIM_RAION     VARCHAR2(60 BYTE),
  KOL            NUMBER,
  KOLVO_1        NUMBER,
  NACH_KOLVO_1   NUMBER,
  KOLVO_2        NUMBER,
  NACH_KOLVO_2   NUMBER,
  MESYAC         VARCHAR2(60 BYTE),
  DAT_MESYAC     DATE
)
ON COMMIT DELETE ROWS
NOCACHE;

--Даю грант на user JASPRI.Потому что все отчеты формируется под этим пользователем 

GRANT DELETE, SELECT, UPDATE ON WG_BZAIM_L_SH TO JASPRI;