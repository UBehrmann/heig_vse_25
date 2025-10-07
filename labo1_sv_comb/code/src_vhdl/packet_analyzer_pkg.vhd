
package packet_analyzer_pkg is

constant LENGTHSIZE : integer := 8;
constant TYPESIZE   : integer := 3;
constant ERRORSIZE  : integer := 8;
constant MAXSIZE    : integer := 6 * 8 + 16 + 255 * 8;

constant GROUPO_LOW  : integer := 0;
constant GROUP0_HIGH : integer := 255;
constant GROUP1_LOW  : integer := 300;
constant GROUP1_HIGH : integer := 400;

end packet_analyzer_pkg;