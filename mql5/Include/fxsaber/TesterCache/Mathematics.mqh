struct MATHEMATICS
{
  long Pass;

  double custom_fitness;      // пользовательский фитнесс - результат OnTester (+)

#define TOSTRING(A) #A + " = " + (string)(A) + "\n"
  string ToString( void ) const
  {
    return(TOSTRING(Pass) + TOSTRING(custom_fitness));
  }
#undef TOSTRING

  double TesterStatistics( const ENUM_STATISTICS Statistic_ID ) const
  {
    return((Statistic_ID == STAT_CUSTOM_ONTESTER) ? this.custom_fitness : 0);
  }

};