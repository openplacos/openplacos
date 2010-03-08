/*  This file is part of Openplacos.

    Openplacos is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Foobar is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
*/

#define SPI_CAN 's'
#define SPI_BUTTERFLY 'b'

#define DD_MISO DDB4
#define DD_MOSI DDB3
#define SCK DDB5
#define SS DDB2

void SPI_MasterInit(void);
void SPI_MasterTransmit(char);
char SPI_MasterReceive(void);
void SPI_SelectSlave(char slave);
void SPI_NoSlave(void);

