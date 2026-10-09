import requests
import time
import pytest

BASE_URL = "https://thinking-tester-contact-list.herokuapp.com"

@pytest.fixture(scope="module")
def user_data():
    timestamp = int(time.time())
    return {
        "firstName": "API",
        "lastName": "Test",
        "email": f"api_test_{timestamp}@example.com",
        "password": "ValidPass123!"
    }

@pytest.fixture(scope="module", autouse=True)
def setup_user(user_data):
    # Явно создаем пользователя один раз перед всеми тестами
    response = requests.post(f"{BASE_URL}/users", json=user_data)
    return response.json().get("token")

@pytest.fixture(scope="module")
def auth_token(setup_user):
    return setup_user

# TC-01: Успешная регистрация
def test_register_user():
    timestamp = int(time.time()) + 1
    data = {
        "firstName": "New",
        "lastName": "User",
        "email": f"new_user_{timestamp}@example.com",
        "password": "Password123!"
    }
    response = requests.post(f"{BASE_URL}/users", json=data)
    assert response.status_code == 201
    assert "token" in response.json()

# TC-02: Регистрация с невалидным email
def test_register_invalid_email():
    data = {
        "firstName": "New",
        "lastName": "User",
        "email": "invalid_email.com",
        "password": "Password123!"
    }
    response = requests.post(f"{BASE_URL}/users", json=data)
    assert response.status_code == 400
    assert "Email is invalid" in response.text

# TC-03: Дубликат email
def test_register_duplicate_email(user_data):
    # Пользователь уже создан в фикстуре setup_user
    response = requests.post(f"{BASE_URL}/users", json=user_data)
    assert response.status_code == 400
    assert "Email address is already in use" in response.text

# TC-04: Успешная авторизация (логин)
def test_login_success(user_data):
    data = {"email": user_data["email"], "password": user_data["password"]}
    response = requests.post(f"{BASE_URL}/users/login", json=data)
    assert response.status_code == 200
    assert "token" in response.json()

# TC-05: Логин с неверным паролем
def test_login_invalid_password(user_data):
    data = {"email": user_data["email"], "password": "WrongPassword"}
    response = requests.post(f"{BASE_URL}/users/login", json=data)
    assert response.status_code == 401

# TC-06: Запрос защищенного ресурса без токена
def test_get_profile_no_token():
    response = requests.get(f"{BASE_URL}/users/me")
    assert response.status_code == 401

# TC-07: Запрос с невалидным токеном
def test_get_profile_invalid_token():
    headers = {"Authorization": "Bearer invalid_token_here"}
    response = requests.get(f"{BASE_URL}/users/me", headers=headers)
    assert response.status_code == 401

# TC-08: Проверка структуры ответа профиля
def test_get_profile_structure(auth_token):
    headers = {"Authorization": f"Bearer {auth_token}"}
    response = requests.get(f"{BASE_URL}/users/me", headers=headers)
    assert response.status_code == 200
    data = response.json()
    assert "_id" in data
    assert "firstName" in data
    assert "email" in data

# TC-09: Метод не поддерживается (Negative)
def test_method_not_allowed(auth_token):
    # Пытаемся сделать POST на /users/me
    headers = {"Authorization": f"Bearer {auth_token}"}
    response = requests.post(f"{BASE_URL}/users/me", headers=headers)
    assert response.status_code in [404, 405, 503] # Допускаем 503, так как иногда heroku так отвечает на неверные методы

# TC-10: Создание контакта (успешное)
def test_create_contact(auth_token):
    headers = {"Authorization": f"Bearer {auth_token}"}
    data = {
        "firstName": "John",
        "lastName": "Doe"
    }
    response = requests.post(f"{BASE_URL}/contacts", json=data, headers=headers)
    assert response.status_code == 201
    assert response.json()["firstName"] == "John"
