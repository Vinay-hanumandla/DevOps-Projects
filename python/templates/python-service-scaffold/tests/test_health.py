"""Liveness and readiness answer different questions on purpose."""
# last_verified: 2026-10-03 · python n/a

from fastapi.testclient import TestClient


def test_liveness_reports_the_running_configuration(client: TestClient) -> None:
    response = client.get("/healthz")

    assert response.status_code == 200
    assert response.json() == {
        "app": "python-service-scaffold",
        "environment": "local",
        "status": "ok",
    }


def test_readiness_runs_a_probe_query(client: TestClient) -> None:
    response = client.get("/healthz/ready")

    assert response.status_code == 200
    assert response.json() == {"database": "ok"}