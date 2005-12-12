#ifndef ___TMPLTCOLL__
#define ___TMPLTCOLL__

#include <list>
#include <iterator>

///////////////////////////////////////////////////////////////
template<class T>
class save_ptr_list : public std::list<T*>
{
public:
  typedef std::list<T*> ptr_list;
  ~save_ptr_list()
  {
    DeleteAll();
  }
  void DeleteAll()
  {
//    typename std::list<T*>::iterator i;
//    for(ptr_list::iterator i = thjs.begin();i!=end();++i)
//      delete (*i);
//    clear();   
  }
};


#include <vector>

///////////////////////////////////////////////////////////////
template<class T>
class save_ptr_vector : public std::vector<T*>
{
public:
  ~save_ptr_vector()
  {
    DeleteAll();
  }
  void DeleteAll()
  {
    typename std::vector<T*>::iterator i;
    for(i = this.begin();i!=this.end();++i)
      delete (*i);
    this.clear();   
  }
};

#endif
