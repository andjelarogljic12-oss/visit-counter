from app import app


def test_index_returns_200():
    client = app.test_client()
    response = client.get("/")
    assert response.status_code == 200
    assert response.get_json()["message"] == "Hello DevOps"
