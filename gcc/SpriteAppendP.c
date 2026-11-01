/* SpriteAppendP.c - Sprite_AppendP, replacing src/Libraries/Sprite/35AppendP.s (the same fix as DeskLib64's, MODIFICATIONS64.md C16).
   OS_SpriteOp 512 + 35, the pointer form, takes the address of the second sprite in R3 as well as that of the first in R2; DeskLib's veneer passed the name of the second
   sprite, which the OS refuses ("SpriteExtend: Can't append sprite", and with some Kernels "SWI &80146 not known").  The second sprite is looked up by name first.  The
   prototype is unchanged. */
#include "DeskLib:Core.h"
#include "DeskLib:SWI.h"
#include "DeskLib:Sprite.h"

os_error *Sprite_AppendP (sprite_area area, sprite_header *sprite1, const char *name2, int dir)
{
  os_error *e;
  sprite_header *sprite2 = NULL;
  e = SWI (3, 3, SWI_OS_SpriteOp | XOS_Bit, 256 + 24, area, name2, NULL, NULL, &sprite2);	/* OS_SpriteOp 24: select name2 */
  if (e) return e;
  return SWI (5, 0, SWI_OS_SpriteOp | XOS_Bit, 512 + 35, area, sprite1, sprite2, dir);		/* OS_SpriteOp 35, pointer form: R2 and R3 are both sprite pointers */
}
