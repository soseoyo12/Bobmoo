import os
from dotenv import load_dotenv

def getAPIkey() -> str:
    '''
    .env 파일에서 API 키를 읽어서 반환합니다.

    Args:
        없음

    Returns:
        str: 환경 변수에서 읽어온 API 키 문자열을 반환합니다. 없을 경우 예외를 발생시킵니다.

    Raises:
        RuntimeError: API_KEY가 비어있거나 존재하지 않을 때 발생합니다.

    Note:
        local.env 파일이 프로젝트 루트에 존재해야 하며 환경 변수 'API_KEY'가 저장되어 있어야 합니다.
    '''
    load_dotenv(dotenv_path="local.env")

    API_KEY = os.getenv("API_KEY", "").strip()
    if not API_KEY:
        raise RuntimeError("환경변수 API_KEY가 비어있습니다. local.env를 확인하세요.")
    
    return API_KEY
