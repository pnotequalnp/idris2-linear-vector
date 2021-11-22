module Data.Linear.Vector

import public Data.Fin
import Data.IOArray.Prims

%default total

unsafePrimIO : PrimIO a -> a
unsafePrimIO = unsafePerformIO . primIO

export
data Vector : Nat -> Type -> Type where
  UnsafeFromPrimArray : ArrayData a -> Vector n a

export
newVector : {n : Nat} -> a -> Vector n a
newVector x = UnsafeFromPrimArray . unsafePrimIO $ prim__newArray (cast n) x

export
readVector : Vector n a -> Fin n -> a
readVector (UnsafeFromPrimArray xs) i = unsafePrimIO $ prim__arrayGet xs (cast (finToNat i))

public export
interface LVector (f : Nat -> Type -> Type) where
  withVector : {n : Nat} -> a -> (1 _ : ((1 _ : f n a) -> b)) -> b
  read : (1 _ : f n a) -> Fin n -> Res a (const (f n a))
  write : (1 _ : f n a) -> Fin n -> a -> f n a
  modify : (1 _ : f n a) -> Fin n -> (a -> a) -> f n a

export
LVector Vector where
  withVector x f =
    let xs := unsafePrimIO $ prim__newArray (cast n) x
     in f $ UnsafeFromPrimArray xs

  read (UnsafeFromPrimArray xs) i =
    unsafePrimIO (prim__arrayGet xs (cast (finToNat i))) # UnsafeFromPrimArray xs

  write (UnsafeFromPrimArray xs) i x =
    unsafePrimIO $ prim__arraySet xs (cast (finToNat i)) x
        `prim__io_bind` const (prim__io_pure (UnsafeFromPrimArray xs))

  modify (UnsafeFromPrimArray xs) i f =
    let i' := cast (finToNat i)
     in unsafePrimIO $ (prim__arrayGet xs i'
            `prim__io_bind` prim__arraySet xs i' . f)
            `prim__io_bind` const (prim__io_pure (UnsafeFromPrimArray xs))
