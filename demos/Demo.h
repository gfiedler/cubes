/*
	Networked Physics Demo
	Copyright © 2008-2011 Glenn Fiedler
	http://www.gafferongames.com/networking-for-game-programmers
*/

#ifndef DEMO_H
#define DEMO_H

#include "PreCompiled.h"
#include "shared/Game.h"
#include "client/View.h"
#include "client/Render.h"

using namespace game;
using namespace view;
#ifdef HAS_OPENGL
using namespace render;
#endif
using namespace engine;
using namespace platform;

const float DeltaTime = 1.0f / 60.0f;

// -------------------------------------------------------------------------

class GameWorkerThread : public WorkerThread
{
public:
	
	GameWorkerThread()
	{
		instance = NULL;
	} 
	
	void Start( game::Interface * instance )
	{
		assert( instance );
		this->instance = instance;
		WorkerThread::Start();
	}
	
	#ifdef HAS_OPENGL
	float GetSimTime() const
	{
		return simTime;
	}
	#endif
	
private:
	
	virtual void Run()
	{
		// TODO: port timer to linux
		#ifdef HAS_OPENGL
		platform::Timer timer;
		#endif
		instance->Update( DeltaTime );
		#ifdef HAS_OPENGL
		simTime = timer.delta();
		#endif
	}
	
	#ifdef HAS_OPENGL
	float simTime;
	#endif
	game::Interface * instance;
};

// ------------------------------------------------------

class Demo
{
public:
	
	virtual ~Demo() {}
	virtual void InitializeWorld() = 0;
	virtual void InitializeRender( int displayWidth, int displayHeight ) = 0;
    virtual void ResizeDisplay( int displayWidth, int displayHeight ) = 0;
	virtual void ProcessInput( const platform::Input & input ) = 0;
	virtual void Update( float deltaTime ) = 0;
	virtual void Render( float deltaTime, bool shadows ) = 0;
	virtual void WaitForSim() = 0;
};

#endif
