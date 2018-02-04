// encode_gdt.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <Windows.h>

#pragma pack(2)
struct GDT_ENTRY {
	union {
		struct {
			WORD Limit0;
			WORD Base0;
			BYTE Base1;
			BYTE AccessAc : 1;
			BYTE AccessRW : 1;
			BYTE AccessDC : 1;
			BYTE AccessEx : 1;
			BYTE AccessSystem : 1;
			BYTE AccessPrivl : 2;
			BYTE AccessPr : 1;
			BYTE Limit1 : 4;
			BYTE Unused : 2;
			BYTE FlagSz : 1;
			BYTE FlagGr : 1;
			BYTE Base2;
		};
		ULONG64 AsULONG64;
	};
};

#pragma pack()

int main()
{
	struct GDT_ENTRY Entry = { 0 };
	Entry.Limit0 = 0xffff;
	Entry.Limit1 = 0xf;
	Entry.FlagSz = 1; // 32 bit selector
	Entry.AccessRW = 1; // Read access
	Entry.AccessEx = 1; // Executable access
	Entry.AccessSystem = 1; // Must be 1
	Entry.AccessPr = 1;
	printf("CS: %I64x\n", Entry.AsULONG64);
	Entry.AccessEx = 0;
	printf("DS: %I64x\n", Entry.AsULONG64);
	Entry.Limit1 = 0;
	Entry.Limit0 = 0x64;
	Entry.Base0 = 0x7c02;
	Entry.AccessEx = 1;
	Entry.AccessSystem = 0;
	Entry.AccessRW = 0;
	Entry.AccessAc = 1;
	printf("TS: %I64x\n", Entry.AsULONG64);
	return 0;
}

