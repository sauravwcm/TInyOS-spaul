#ifndef WI_SHOW_H
#define WI_SHOW_H
typedef nx_struct WsnMsg
 {
 	nx_uint16_t NodeID;
 	nx_uint16_t  Data;
 }WsnMsg_t;
 
 enum
 {
 	AM_RADIO = 6
 }; 
#endif /* WI_SHOW_H */
