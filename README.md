<<<<<<< HEAD
# dal-polyfill

## 한국어
Dal에서 Luau -> Lua(특히 Lua 5.3)로 트렌스파일링시 필요한 폴리필 라이브러리

### 노트
- 해당 라이브러리 소스코드는 Lua 5.3에서 동작하도록 설계되었으며, 개발시 정확한 타입체크를 위해 루아우 타입이 사용되어 `darklua` 변환없이는 Luau에서도 Lua 5.3에서도 실행 불가능한 상태입니다.

### 작동 방식
- Dal에서 이 저장소를 `git clone`하여 사용자 컴퓨터 캐시에 저장한 뒤 `darklua`를 사용하여 하나의 모듈로 번들링하여 주입시키는 방식으로 작동합니다.

### 구현
#### Globals
- [x] `typeof`
- [x] `unpack`
- [x] `pairsWithHash` (uses `djb2` hashing internally which isn't equivalent to Luau's)
- [x] `newproxy`
- [x] `gcinfo`

#### Libraries
- [x] `buffer`
- [x] `math`
- [x] `os` (sandboxed)
- [x] `string`
- [x] `table`

## English
Polyfill libraries for dal used transpiling luau to lua (especially Lua 5.3)
=======

[한국어](README_kr.md) 👈
# English

## dal-polyfill
Polyfill libraries for dal used transpiling luau to lua (especially Lua 5.3)

### Implementations
#### Globals
- [x] `typeof`
- [x] `unpack`
- [x] `pairsWithHash` (uses `djb2` hashing internally which isn't equivalent to Luau's)
- [x] `newproxy`
- [x] `gcinfo`
- More details [here](libs/globals.luau)

#### Libraries
- [x] `buffer`
- [x] `math`
- [x] `os` (sandboxed)
- [x] `string`
- [x] `table`
- [x] `debug`
- [x] `bit32`
>>>>>>> d044ffc3966df21a5ac0de8a43c85d7a853d46bd
