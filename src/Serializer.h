#ifndef _SERIALIZE_H
#define _SERIALIZE_H

#include "libs.h"
#include "Quaternion.h"
#include <vector>

class Frame;
class Body;
class StarSystem;
class SBody;

struct SavedGameCorruptException {};
struct CouldNotOpenFileException {};

namespace Serializer {
	
	bool SaveGame(const char *filename);
	void LoadGame(const char *filename);

	void IndexFrames();
	Frame *LookupFrame(size_t index);
	int LookupFrame(const Frame *f);

	void IndexBodies();
	Body *LookupBody(size_t index);
	int LookupBody(const Body *);

	void IndexSystemBodies(StarSystem *);
	SBody *LookupSystemBody(size_t index);
	int LookupSystemBody(const SBody*);

	class Writer {
	public:
		Writer() {}
		const std::string &GetData();
		void Byte(Uint8 x);
		void Bool(bool x);
		void Int16(Uint16 x);
		void Int32(Uint32 x);
		void Int64(Uint64 x);
		void Float(float f);
		void Double(double f);
		void String(const char* s);
		void String(const std::string &s);
		void Vector3d(vector3d vec);
		void WrQuaternionf(const Quaternionf &q);
		void WrSection(const std::string &section_label, const std::string &section_data) {
			String(section_label);
			String(section_data);
		}
		/** Best not to use these except in templates */
		void Auto(Sint32 x) { Int32(x); }
		void Auto(Sint64 x) { Int64(x); }
		void Auto(float x) { Float(x); }
		void Auto(double x) { Double(x); }
	private:
		std::string m_str;
	};

	class Reader {
	public:
		Reader();
		Reader(const std::string &data);
		Reader(FILE *fptr);
		bool AtEnd();
		void Seek(int pos);
		Uint8 Byte();
		bool Bool();
		Uint16 Int16();
		Uint32 Int32();
		Uint64 Int64();
		float Float ();
		double Double ();
		std::string String();
		char* Cstring();
		void Cstring2(char *buf, int len);
		vector3d Vector3d();
		Quaternionf RdQuaternionf();
		Reader RdSection(const std::string &section_label_expected) {
			if (section_label_expected != String()) {
				throw SavedGameCorruptException();
			}
			return Reader(String());
		}
		/** Best not to use these except in templates */
		void Auto(Sint32 *x) { *x = Int32(); }
		void Auto(Sint64 *x) { *x = Int64(); }
		void Auto(float *x) { *x = Float(); }
		void Auto(double *x) { *x = Double(); }
		int StreamVersion() const { return m_streamVersion; }
		void SetStreamVersion(int x) { m_streamVersion = x; }
	private:
		std::string m_data;
		int m_pos;
		int m_streamVersion;
	};


}

#endif /* _SERIALIZE_H */
