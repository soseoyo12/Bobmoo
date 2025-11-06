import os
from enum import Enum
from typing import Optional
from dotenv import load_dotenv

class ApiProvider(Enum):
    GEMINI = "GEMINI_API_KEY"
    UPSTAGE = "UPSTAGE_API_KEY"


def getAPIkey(provider: Optional[ApiProvider] = None) -> str:
    '''
    .env 파일에서 지정한 제공자에 해당하는 API 키를 읽어서 반환합니다.

    Args:
        provider (Optional[ApiProvider]): 선택한 API 제공자. 지정하지 않으면 레거시 'API_KEY'를 사용합니다.

    Returns:
        str: 환경 변수에서 읽어온 API 키 문자열을 반환합니다. 없을 경우 예외를 발생시킵니다.

    Raises:
        RuntimeError: 지정된 환경변수 키가 비어있거나 존재하지 않을 때 발생합니다.

    Note:
        local.env 파일이 프로젝트 루트에 존재해야 하며 다음 중 하나의 환경 변수가 저장되어 있어야 합니다.
        - 'GEMINI_API_KEY'
        - 'UPSTAGE_API_KEY' # provider를 지정하지 않은 경우에만 사용

    예시:
        getAPIkey(ApiProvider.UPSTAGE) -> 'UPSTAGE_API_KEY' 값을 반환
        getAPIkey(ApiProvider.GEMINI)  -> 'GEMINI_API_KEY' 값을 반환
        getAPIkey()                    -> (호환) 'UPSTAGE_API_KEY' 값을 반환
    '''
    load_dotenv(dotenv_path="local.env")

    env_var_name = "UPSTAGE_API_KEY" if provider is None else provider.value
    api_key = os.getenv(env_var_name, "").strip()
    if not api_key:
        raise RuntimeError(f"환경변수 {env_var_name}가 비어있습니다. local.env를 확인하세요.")
    
    return api_key
