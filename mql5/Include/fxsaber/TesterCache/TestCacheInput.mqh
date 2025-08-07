#include "String.mqh"
#include "TestInputRange.mqh"
#include <TypeToBytes.mqh> // https://www.mql5.com/ru/code/16280

#define TYPE_OFFSET 75

#define INT64 long
// https://www.mql5.com/ru/forum/1111/page2440#comment_11395809
//+------------------------------------------------------------------+
//| входные параметры тестирования                                   |
//+------------------------------------------------------------------+
struct TestCacheInput
{
  //   wchar_t           name[64];
  STRING64          name;
  int               flag;                    // оптимизируемый параметр
  int               type;                    // тип TYPE_XXX
  int               digits;                  // количество знаков после запятой
  int               offset;                  // смещение в буфере параметров
  int               size;                    // размер значения параметра в буфере
  int Unknown;
  //--- 0-start,1-step,2-stop
  union SSS
  {
    TestInputRange<INT64> Integer;
    TestInputRange<double> Number;

    string ToString( void ) const
    {
      return(this.Integer.ToString() + this.Number.ToString());
    }

  } StartStepStop;

#define TOSTRING(A) #A + " = " + (string)(A) + "\n"
  string ToString( void ) const
  {
    return(
           "name = " + name[] + "\n" +
           TOSTRING(flag) +
           TOSTRING(type) +
           TOSTRING(digits) +
           TOSTRING(offset) +
           TOSTRING(size) +
           StartStepStop.ToString()
          );
  }
#undef TOSTRING

#define MACROS(A)        \
  {                      \
    A Value = NULL;      \
    _W(Value) = Bytes;   \
                         \
    Str = (string)Value; \
                         \
    break;               \
  }

  string ToString( const uchar &Buffer[] ) const
  {
    string Str = NULL;
    uchar Bytes[];

    ::ArrayCopy(Bytes, Buffer, 0, this.offset, this.size);

    switch (this.type - TYPE_OFFSET)
    {
    case TYPE_BOOL:
      MACROS(bool)
    case TYPE_CHAR:
      MACROS(char)
    case TYPE_UCHAR:
      MACROS(uchar)
    case TYPE_SHORT:
      MACROS(short)
    case TYPE_USHORT:
      MACROS(ushort)
    case TYPE_COLOR:
      MACROS(color)
    case TYPE_INT:
      MACROS(int)
    case TYPE_UINT:
      MACROS(uint)
    case TYPE_DATETIME:
      MACROS(datetime)
    case TYPE_LONG:
      MACROS(long)
    case TYPE_ULONG:
      MACROS(ulong)
    case TYPE_FLOAT:
    case TYPE_DOUBLE:
      MACROS(double)
    case TYPE_STRING:
      {
        short Words[];
        ::_ArrayCopy(Words, Bytes);

        Str = ::ShortArrayToString(Words);
        break;
      }
    default:
      MACROS(int)
    }

    return(Str);
  }
#undef MACROS
};

#undef INT64

/*
   m_header.header_size=sizeof(TestCacheHeader)+m_inputs.Total()*sizeof(TestCacheInput)+m_header.parameters_size;
//--- кешируемая запись содержит номер прохода (при генетике - номер по порядку), структуру результатов тестирования (если математика, то 1 double), буфер оптимизируемых параметров и генетический проход
   m_header.record_size=sizeof(INT64)+m_header.opt_params_size;
   if(m_mathematics)
      m_header.record_size+=sizeof(double);
   else
      m_header.record_size+=sizeof(ExpTradeSummary);
   if(m_header.dwords_cnt>1)
      m_header.record_size+=m_header.dwords_cnt*sizeof(DWORD);
   else
     {
      if(m_genetics)
         m_header.record_size+=sizeof(INT64);
     }
*/