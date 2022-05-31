
// ----------------------------------------------------------------
// Module
// ----------------------------------------------------------------

module VSP;

// ----------------------------------------------------------------
// Imports
// ----------------------------------------------------------------

version(Windows) {
	import core.sys.windows.windows;
	import core.sys.windows.dll;
}

// strcmp
import core.stdc.string;

// ----------------------------------------------------------------
// General definitions
// ----------------------------------------------------------------

// Aliases
alias extern(C) void* function(const char* szName, int* pReturnCode) CreateInterfaceFn;
alias extern(C) void* function() InstantiateInterfaceFn;
alias extern(C) void function(const char* msg, ...) fnMsg;

// Enums
enum : int {
	IFACE_OK = 0,
	IFACE_FAILED = 1
};

alias int PLUGIN_STATUS;
enum : PLUGIN_STATUS {
	PLUGIN_CONTINUE = 0,
	PLUGIN_OVERRIDE = 1,
	PLUGIN_STOP = 2
};

// ----------------------------------------------------------------
// InterfaceReg
// ----------------------------------------------------------------

extern(C++) class InterfaceReg {
public:
	this(InstantiateInterfaceFn pFn, const char* szName) {
		m_CreateFn = pFn;
		m_szName = szName;
		m_pNext = g_pInterfaceRegs;
		g_pInterfaceRegs = cast(void*)(this);
	};

public:
	InstantiateInterfaceFn m_CreateFn;
	const char* m_szName;
	void* m_pNext;
	__gshared static void* g_pInterfaceRegs = null;
};

// ----------------------------------------------------------------
// CreateInterface
// ----------------------------------------------------------------

void* CreateInterfaceInternal(const char* szName, int* pReturnCode) {
	if (!InterfaceReg.g_pInterfaceRegs) {
		if (pReturnCode){
			*pReturnCode = IFACE_FAILED;
		}
		return null;
	}

	if (!szName) {
		if (pReturnCode){
			*pReturnCode = IFACE_FAILED;
		}
		return null;
	}

	for (InterfaceReg pInterface = cast(InterfaceReg)(InterfaceReg.g_pInterfaceRegs); pInterface; pInterface = cast(InterfaceReg)(pInterface.m_pNext)) {
		if (strcmp(pInterface.m_szName, szName) == 0) {
			if (pReturnCode) {
				*pReturnCode = IFACE_OK;
			}
			return pInterface.m_CreateFn();
		}
	}

	if (pReturnCode) {
		*pReturnCode = IFACE_FAILED;
	}

	return null;
}

export extern(C) void* CreateInterface(const char* szName, int* pReturnCode) {
	return CreateInterfaceInternal(szName, pReturnCode);
}

// ----------------------------------------------------------------
// IServerPluginCallbacks
// ----------------------------------------------------------------

extern(C++) interface IServerPluginCallbacks {
	bool Load(CreateInterfaceFn pInterfaceFactory, CreateInterfaceFn pGameServerFactory);
	void UnLoad();
	void Pause();
	void UnPause();
	const char* GetDescription();
	void LevelInit(const char* szMapName);
	void ServerActivate(void* pEdictList, int nEdictCount, int nClientMax);
	void GameFrame(bool bIsSimulating);
	void LevelShutdown();
	void ClientActive(void* pEdict);
	void ClientDisconnect(void* pEdict);
	void ClientPutInServer(void* pEdict, const char* szPlayerName);
	void SetCommandClient(int nIndex);
	void ClientSettingsChanged(void* pEdict);
	PLUGIN_STATUS ClientConnect(bool* pAllowConnect, void* pEdict, const char* szName, const char* szAddress, char* szRejectMessage, int nRejectMessageLength);
	PLUGIN_STATUS ClientCommand(void* pEdict, const void* pArgs);
	PLUGIN_STATUS NetworkIDValidated(const char* szUserName, const char* szNetworkID);
	void OnQueryCvarValueFinished(int nCookie, void* pPlayerEdict, int nStatus, const char* pCVarName, const char* pCVarValue);
	void OnEdictAllocated(void* pEdict);
	void OnEdictFreed(const void* pEdict);
}

// ----------------------------------------------------------------
// ValveSourcePlugin
// ----------------------------------------------------------------

extern(C++) class ValveSourcePlugin : IServerPluginCallbacks {
public:
	this() {
		m_nCommandClientIndex = 0;
	}

	~this() {
		// Nothing...
	}

public:
	bool Load(CreateInterfaceFn pInterfaceFactory, CreateInterfaceFn pGameServerFactory) {
		version(Windows) {
			HMODULE hTier0 = GetModuleHandle("tier0.dll");
			if (!hTier0) {
				return false;
			}

			fnMsg Msg = cast(fnMsg)(GetProcAddress(hTier0, "Msg"));
			if (!Msg) {
				return false;
			}

			Msg("[D] Loaded successful.\n");
		}
		return true;
	};

	void UnLoad() {
	};

	void Pause() {
	};

	void UnPause() {
	};

	const char* GetDescription() {
		return cast(char*)("Just D-Lang plugin...");
	};

	void LevelInit(const char* szMapName) {
	};

	void ServerActivate(void* pEdictList, int nEdictCount, int nClientMax) {
	};

	void GameFrame(bool bIsSimulating) {
	};

	void LevelShutdown() {
	};

	void ClientActive(void* pEdict) {
	};

	void ClientDisconnect(void* pEdict) {
	};

	void ClientPutInServer(void* pEdict, const char* szPlayerName) {
	};

	void SetCommandClient(int nIndex) {
		m_nCommandClientIndex = nIndex;
	};

	void ClientSettingsChanged(void* pEdict) {
	};

	PLUGIN_STATUS ClientConnect(bool* pAllowConnect, void* pEdict, const char* szName, const char* szAddress, char* szRejectMessage, int nRejectMessageLength) {
		return PLUGIN_CONTINUE;
	};

	PLUGIN_STATUS ClientCommand(void* pEdict, const void* pArgs) {
		return PLUGIN_CONTINUE;
	};

	PLUGIN_STATUS NetworkIDValidated(const char* szUserName, const char* szNetworkID) {
		return PLUGIN_CONTINUE;
	};

	void OnQueryCvarValueFinished(int nCookie, void* pPlayerEdict, int nStatus, const char* pCVarName, const char* pCVarValue) {
	};

	void OnEdictAllocated(void* pEdict) {
	};

	void OnEdictFreed(const void* pEdict) {
	};

public:
	int GetCommandClient() {
		return m_nCommandClientIndex;
	}

private:
	int m_nCommandClientIndex;
}

// ----------------------------------------------------------------
// Creating interface for VSP
// ----------------------------------------------------------------

extern(C) {
	__gshared static IServerPluginCallbacks g_ValveSourcePlugin = new ValveSourcePlugin();
	__gshared static InterfaceReg PluginReg = null;
	static void* GetPluginInterface() {
		return cast(void*)(&g_ValveSourcePlugin.__vptr);
	}
}

// ----------------------------------------------------------------
// Main (Windows)
// ----------------------------------------------------------------

version(Windows) {
	extern(Windows) BOOL DllMain(HINSTANCE hinstDLL, DWORD fdwReason, LPVOID lpReserved) {
		switch (fdwReason) {
			case DLL_PROCESS_ATTACH: {
				dll_process_attach( hinstDLL, true );
				// Plugin interface initialization
				PluginReg = new InterfaceReg(cast(InstantiateInterfaceFn)(&GetPluginInterface), "ISERVERPLUGINCALLBACKS003");
				break;
			}

			case DLL_PROCESS_DETACH: {
				dll_process_detach( hinstDLL, true );
				break;
			}

			case DLL_THREAD_ATTACH: {
				dll_thread_attach( true, true );
				break;
			}

			case DLL_THREAD_DETACH: {
				dll_thread_detach( true, true );
				break;
			}

			default: {
				break;
			}
		}

		return true;
	}
}
