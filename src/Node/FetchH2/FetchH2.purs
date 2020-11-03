module Node.FetchH2
  ( ContextOptions
  , mkContext
  , Context
  , URL(..)
  , class HasFetchH2
  , fetchH2ContextL
  , Fetch
  , Options
  , Response
  , Headers
  , Credentials
  , Redirect
  , InternalContext
  , omitCredentials
  , sameOriginCredentials
  , includeCredentials
  , Method
  , getMethod
  , putMethod
  , postMethod
  , deleteMethod
  , headMethod
  , redirectError
  , redirectFollow
  , redirectManual
  , makeHeaders
  , defaultFetchOptions
  , fetch
  , json
  , text
  , headers
  , arrayBuffer
  , statusCode
  , httpVersion
  , url
  , fetch2
  ) where

import Prelude
import Control.Promise (Promise, toAffE)
import Data.Argonaut.Core (Json)
import Data.ArrayBuffer.Types (ArrayBuffer)
import Data.Lens (Lens')
import Data.Newtype (class Newtype)
import Effect (Effect)
import Effect.Aff (Aff)
import Foreign.Object (Object)
import Foreign.Object as Object
import Type.Row (class Union)
import Type.Row.Homogeneous (class Homogeneous)
import Unsafe.Coerce (unsafeCoerce)

class HasFetchH2 env where
  fetchH2ContextL :: Lens' env Context

-- TODO: fill in options
-- https://github.com/grantila/fetch-h2/blob/d0c863c9a9d786ce518bbaae9e53adb4599964d1/lib/context.ts#L52
type ContextOptions
  = ()

newtype Context
  = Context { fetch :: Fetch }

mkContext ::
  forall options trash.
  Union options trash ContextOptions =>
  { | options } ->
  Effect Context
mkContext opts = do
  context <- _context opts
  pure
    $ Context
        { fetch: fetch2 context
        }

newtype URL
  = URL String

derive instance newtypeURL :: Newtype URL _

derive newtype instance showURL :: Show URL

derive instance eqURL :: Eq URL

type Fetch
  = forall options trash.
    Union options trash Options =>
    URL ->
    Record ( method :: Method | options ) ->
    Aff Response

type Options
  = ( method :: Method
    , body :: String
    , headers :: Headers
    , credentials :: Credentials
    , follow :: Int
    , redirect :: Redirect
    )

-- | See <https://developer.mozilla.org/en-US/docs/Web/API/Request/credentials>.
foreign import data Credentials :: Type

omitCredentials :: Credentials
omitCredentials = unsafeCoerce "omit"

sameOriginCredentials :: Credentials
sameOriginCredentials = unsafeCoerce "same-origin"

includeCredentials :: Credentials
includeCredentials = unsafeCoerce "include"

foreign import data Method :: Type

foreign import showMethodImpl :: Method -> String

instance showMethod :: Show Method where
  show = showMethodImpl

getMethod :: Method
getMethod = unsafeCoerce "GET"

postMethod :: Method
postMethod = unsafeCoerce "POST"

putMethod :: Method
putMethod = unsafeCoerce "PUT"

deleteMethod :: Method
deleteMethod = unsafeCoerce "DELETE"

headMethod :: Method
headMethod = unsafeCoerce "HEAD"

foreign import data Redirect :: Type

redirectError :: Redirect
redirectError = unsafeCoerce "error"

redirectFollow :: Redirect
redirectFollow = unsafeCoerce "follow"

redirectManual :: Redirect
redirectManual = unsafeCoerce "manual"

type Headers
  = Object.Object String

makeHeaders ::
  forall r.
  Homogeneous r String =>
  Record r ->
  Headers
makeHeaders = Object.fromHomogeneous

defaultFetchOptions :: { method :: Method }
defaultFetchOptions =
  { method: getMethod
  }

fetch :: Fetch
fetch url' opts = toAffE $ _fetch url' opts

json :: Response -> Aff Json
json res = toAffE (jsonImpl res)

text :: Response -> Aff String
text res = toAffE (textImpl res)

headers :: Response -> Object String
headers = headersImpl

arrayBuffer :: Response -> Aff ArrayBuffer
arrayBuffer res = toAffE (arrayBufferImpl res)

statusCode :: Response -> Int
statusCode response = response'.status
  where
  response' :: { status :: Int }
  response' = unsafeCoerce response

httpVersion :: Response -> Int
httpVersion response = (unsafeCoerce response).httpVersion

url :: Response -> URL
url response = URL response'.url
  where
  response' :: { url :: String }
  response' = unsafeCoerce response

foreign import data Response :: Type

foreign import _fetch ::
  forall options.
  URL ->
  Record options ->
  Effect (Promise Response)

foreign import _fetch2 ::
  forall options.
  InternalContext ->
  URL ->
  Record options ->
  Effect (Promise Response)

fetch2 ::
  InternalContext ->
  Fetch
fetch2 ctx url' opts = toAffE $ _fetch2 ctx url' opts

foreign import _context ::
  forall options.
  Record options ->
  Effect (InternalContext)

foreign import jsonImpl :: Response -> Effect (Promise Json)

foreign import textImpl :: Response -> Effect (Promise String)

foreign import headersImpl :: Response -> Object String

foreign import arrayBufferImpl :: Response -> Effect (Promise ArrayBuffer)

foreign import data InternalContext :: Type
