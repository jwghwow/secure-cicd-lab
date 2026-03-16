from app.app import app


def test_home():
    client = app.test_client()
    response = client.get("/")

    expected = {"message": "Hello from the secure CI/CD lab"}
    assert response.status_code == 200
    assert response.get_json() == expected


def test_health():
    client = app.test_client()
    response = client.get("/health")

    assert response.status_code == 200
    assert response.get_json() == {"status": "ok"}
