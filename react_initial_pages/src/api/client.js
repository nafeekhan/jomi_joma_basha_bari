const API_BASE_URL = process.env.REACT_APP_API_BASE_URL || 'http://localhost:3000';

const buildHeaders = (options = {}) => {
  const headers = options.headers ? { ...options.headers } : {};
  const token = localStorage.getItem('authToken');
  if (token) {
    headers.Authorization = `Bearer ${token}`;
  }
  if (!options.skipJson && !(options.body instanceof FormData)) {
    headers['Content-Type'] = headers['Content-Type'] || 'application/json';
  }
  return headers;
};

const handleResponse = async (response) => {
  if (!response.ok) {
    let message = response.statusText;
    try {
      const data = await response.json();
      message = data.message || JSON.stringify(data);
    } catch (error) {
      // Ignore JSON parse errors for non-JSON responses
    }
    throw new Error(message || 'Request failed');
  }

  const contentType = response.headers.get('content-type') || '';
  if (contentType.includes('application/json')) {
    return response.json();
  }
  return response.text();
};

export const apiRequest = async (path, { method = 'GET', body, headers, skipJson = false } = {}) => {
  const url = path.startsWith('http') ? path : `${API_BASE_URL}${path}`;

  const init = {
    method,
    headers: buildHeaders({ headers, body, skipJson }),
    credentials: 'include',
  };

  if (body instanceof FormData) {
    init.body = body;
  } else if (body !== undefined && body !== null) {
    init.body = skipJson ? body : JSON.stringify(body);
  }

  const response = await fetch(url, init);
  return handleResponse(response);
};

export const apiGet = (path) => apiRequest(path, { method: 'GET' });
export const apiPost = (path, body, options = {}) =>
  apiRequest(path, { method: 'POST', body, ...options });
export const apiPut = (path, body, options = {}) =>
  apiRequest(path, { method: 'PUT', body, ...options });
