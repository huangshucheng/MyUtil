#ifndef NISMARTPOINTER_H
#define NISMARTPOINTER_H

// Smart pointers. The class T must be derived from NiRefObject.

template <class T> class NiPointer
{
public:
	// construction and destruction
	NiPointer(T* pObject = (T*)0);
	NiPointer(const NiPointer& ptr);
	~NiPointer();

	// implicit conversions
	operator T*() const;
	T& operator*() const;
	T* operator->() const;

	// assignment
	NiPointer& operator=(const NiPointer& ptr);
	NiPointer& operator=(T* pObject);

	// comparisons
	bool operator==(T* pObject) const;
	bool operator!=(T* pObject) const;
	bool operator==(const NiPointer& ptr) const;
	bool operator!=(const NiPointer& ptr) const;

protected:
	// the managed pointer
	T* m_pObject;
};

#define NiSmartPointer(classname) \
class classname; \
	typedef NiPointer<classname> classname##Ptr;


// Use for casting a smart pointer of one type to a pointer or smart pointer
// of another type.
#define NiSmartPointerCast(type, smartptr) ((type*) (void*) (smartptr))

//---------------------------------------------------------------------------
template <class T>
inline NiPointer<T>::NiPointer(T* pObject)
{
	m_pObject = pObject;
	if (m_pObject)
		m_pObject->IncRefCount();
}
//---------------------------------------------------------------------------
template <class T>
inline NiPointer<T>::NiPointer(const NiPointer& ptr)
{
	m_pObject = ptr.m_pObject;
	if (m_pObject)
		m_pObject->IncRefCount();
}
//---------------------------------------------------------------------------
template <class T>
inline NiPointer<T>::~NiPointer()
{
	if (m_pObject)
		m_pObject->DecRefCount();
}
//---------------------------------------------------------------------------
template <class T>
inline NiPointer<T>::operator T*() const
{
	return m_pObject;
}
//---------------------------------------------------------------------------
template <class T>
inline T& NiPointer<T>::operator*() const
{
	return *m_pObject;
}
//---------------------------------------------------------------------------
template <class T>
inline T* NiPointer<T>::operator->() const
{
	return m_pObject;
}
//---------------------------------------------------------------------------
template <class T>
inline NiPointer<T>& NiPointer<T>::operator=(const NiPointer& ptr)
{
	if (m_pObject != ptr.m_pObject)
	{
		if (m_pObject)
			m_pObject->DecRefCount();
		m_pObject = ptr.m_pObject;
		if (m_pObject)
			m_pObject->IncRefCount();
	}
	return *this;
}
//---------------------------------------------------------------------------
template <class T>
inline NiPointer<T>& NiPointer<T>::operator=(T* pObject)
{
	if (m_pObject != pObject)
	{
		if (m_pObject)
			m_pObject->DecRefCount();
		m_pObject = pObject;
		if (m_pObject)
			m_pObject->IncRefCount();
	}
	return *this;
}
//---------------------------------------------------------------------------
template <class T>
inline bool NiPointer<T>::operator==(T* pObject) const
{
	return (m_pObject == pObject);
}
//---------------------------------------------------------------------------
template <class T>
inline bool NiPointer<T>::operator!=(T* pObject) const
{
	return (m_pObject != pObject);
}
//---------------------------------------------------------------------------
template <class T>
inline bool NiPointer<T>::operator==(const NiPointer& ptr) const
{
	return (m_pObject == ptr.m_pObject);
}
//---------------------------------------------------------------------------
template <class T>
inline bool NiPointer<T>::operator!=(const NiPointer& ptr) const
{
	return (m_pObject != ptr.m_pObject);
}
//---------------------------------------------------------------------------

#endif // NISMARTPOINTER_H
