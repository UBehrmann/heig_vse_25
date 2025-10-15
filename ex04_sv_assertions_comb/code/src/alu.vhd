-----------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- Institut REDS
--
-- Composant    : alu
-- Description  : Unité arithmétique et logique capable d'effectuer
--                8 opérations. Un paramètre générique permet de forcer
--                des erreurs.
-- Auteur       : Yann Thoma
-- Date         : 28.02.2012
-- Version      : 1.0
--
-----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
generic (
	SIZE  : integer := 8;
	ERRNO : integer range 0 to 31 := 0
);
port (
	a_i    : in  std_logic_vector(SIZE-1 downto 0);
	b_i    : in  std_logic_vector(SIZE-1 downto 0);
	s_o    : out std_logic_vector(SIZE-1 downto 0);
	c_o    : out std_logic;
	mode_i : in  std_logic_vector(2 downto 0)
);
end alu;

`protect begin_protected
`protect version = 1
`protect encrypt_agent = "QuestaSim" , encrypt_agent_info = "2020.1"
`protect key_keyowner = "Mentor Graphics Corporation" , key_keyname = "MGC-VERIF-SIM-RSA-2"
`protect key_method = "rsa"
`protect encoding = ( enctype = "base64" , line_length = 64 , bytes = 256 )
`protect key_block
M8JKrl6bu0lyCnddPi4o+8dretyI7ktniWTiiOxTZPMrtx5ag5Ay1amrHnvrlGDg
geBuQSzRs00Kh9GdxkhZ+zaN645sjkkdjZIoQpq8VLXzVmmWJOEl8gr/XWe41PlC
VWb2MfFAPTQ384gt5f/yh3CNi5oQxUyqIf58k3/4EXHVqA116igLxJNJ2Opue9zH
TlqpFZSclwWozy6zb7BJNnoOjorSZCSrpBFI4zDwjUrjwDj4tyG6EZObzdS4+Dy+
Cbkzu8hMng65zMQmg3erHKDt0+KsKhNC1Ko+b812qsnqHVpDxFXvhMocuUbRlAya
evwaq8FTk56CcljtdXNUug==
`protect data_method = "aes128-cbc"
`protect encoding = ( enctype = "base64" , line_length = 64 , bytes = 1872 )
`protect data_block
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
`protect end_protected