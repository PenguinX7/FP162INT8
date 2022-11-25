#include <stdio.h>
#include <stdbool.h>

int main()
{
    unsigned short data_i = 0x47af;
    unsigned short data_o;

    bool sign;
    unsigned rmcache;
    bool overflow;
    bool zero;
    bool ifround;

    sign = data_i >> 15;                                        //data_i[15]
    switch((data_i & 0x7c00) >> 10)                             //case(data_i[14:10])
    {
        case 21 : 
        {
            rmcache = 0x40 | ((data_i & 0x03f0) >> 4);          //{1,data_i[9:4]}
            ifround = (data_i & 0x0008) && ((data_i & 0x0010) || (data_i & 0x0007));//data_i[3] && (data_i[4] || |data_i[2:0])
            overflow = 0;
            zero = 0;
        }break;
        case 20 :
        {
            rmcache = 0x20 | ((data_i &0x03e0) >> 5);           //{1,data_i[9:5]}
            ifround = (data_i & 0x0010) && ((data_i & 0x0020) || (data_i & 0x000f));//data_i[4] && (data_i[5] || |data_i[3:0])
            overflow = 0;
            zero = 0;
        }break;
        case 19 :
        {
            rmcache = 0x10 | ((data_i &0x03c0) >> 6);           //{1,data_i[9:6]}
            ifround = (data_i & 0x0020) && ((data_i & 0x0040) || (data_i & 0x001f));//data_i[5] && (data_i[6] || |data_i[4:0])
            overflow = 0;
            zero = 0;
        }break;
        case 18 :
        {
            rmcache = 0x08 | ((data_i & 0x0380) >> 7);          //{1,data_i[9:7]}
            ifround = (data_i & 0x0040) && ((data_i & 0x0080) || (data_i & 0x003f));//data_i[6] && (data_i[7] || |data_i[5:0])
            overflow = 0;
            zero = 0;
        }break;
        case 17 :
        {
            rmcache = 0x04 | ((data_i & 0x0300) >> 8);          //{1,data_i[9:8]}
            ifround = (data_i & 0x0080) && ((data_i & 0x0100) || (data_i & 0x007f));//data_i[7] && (data_i[8] || |data_i[6:0])
            overflow = 0;
            zero = 0;
        }break;
        case 16 :
        {
            rmcache = 0x02 | ((data_i & 0x0200) >> 9);          //{1,data_i[9]}
            ifround = (data_i & 0x0100) && ((data_i & 0x0200) || (data_i & 0x00ff));//data_i[8] && (data_i[9] || |data_i[7:0])
            overflow = 0;
            zero = 0;
        }break;
        case 15 :
        {
            rmcache = 0x01;                                     //1
            ifround = data_i & 0x0200;                          //data_i[9]
            overflow = 0;
            zero = 0;
        }break;
        case 14 :
        {
            rmcache = 0x00;                                     //0
            ifround = data_i & 0x03ff;                          //|data_i[9:0]
            overflow = 0;
            zero = 0;
        }break;
        default : 
        {
            if(((data_i & 0x7c00) >> 10) > 21)
            {
                overflow = 1;
                zero = 0;
            }
            else
            {
                overflow = 0;
                zero = 1;
            }
            rmcache = rmcache;
            ifround = ifround;
        }break;
    }

    if(!(overflow || zero))
        rmcache = ifround ? rmcache + 1 :rmcache;
    else
        rmcache = rmcache;

    if(!(overflow || zero))
        overflow = rmcache & 0x80 ? 1 : overflow;           //overflow = rmcache[7] ? 1 : overflow
    else
        overflow = overflow;

    if(overflow && ~zero)               //{overflow,zero} = 10
        data_o = 0xff;
    else if(~overflow && zero)          //{overflow,zero} = 01
        data_o = 0x00;
    else
        data_o = (sign << 7) | (rmcache & 0x7f);    //{overflow,zero}=00

    return 0;

}