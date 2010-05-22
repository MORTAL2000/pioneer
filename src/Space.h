#ifndef _SPACE_H
#define _SPACE_H

#include <list>
#include "Object.h"
#include "vector3.h"
#include "Serializer.h"

class Body;
class Frame;
class SBody;
struct SBodyPath;
class Ship;

// The place all the 'Body's exist in
namespace Space {
	extern void Init();
	extern void Clear();
	extern void BuildSystem();
	extern void Serialize(Serializer::Writer &wr);
	extern void Unserialize(Serializer::Reader &rd);
	extern void GenBody(SBody *b, Frame *f);
	extern void TimeStep(float step);
	extern void AddBody(Body *);
	extern void RemoveBody(Body *);
	extern void KillBody(Body *);
	extern void RadiusDamage(Body *attacker, Frame *f, const vector3d &pos, double radius, double kgDamage);
	extern void DoECM(const Frame *f, const vector3d &pos, int power_val);
	extern float GetHyperspaceAnim();
	extern void Render(const Frame *cam_frame);
	extern void StartHyperspaceTo(Ship *s, const SBodyPath *);
	extern void DoHyperspaceTo(const SBodyPath *);
	// make sure SBody* is in Pi::currentSystem
	extern Frame *GetFrameWithSBody(const SBody *b);
	extern Body *FindNearestTo(const Body *b, Object::Type t);

	extern std::list<Body*> bodies;
	typedef std::list<Body*>::iterator bodiesIter_t;
	extern Frame *rootFrame;
}


#endif /* _SPACE_H */
