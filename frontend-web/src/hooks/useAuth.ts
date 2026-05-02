// src/hooks/useAuth.ts
import { createContext, useContext, useState, useCallback, ReactNode, createElement } from 'react';
import { authApi } from '../services/api';
import type { User } from '../types';

interface AuthContextValue {
  user: User | null;
  login: (email: string, password: string) => Promise<void>;
  register: (data: {
    email: string; password: string;
    firstName: string; lastName: string; phone?: string;
  }) => Promise<void>;
  logout: () => void;
  isAuthenticated: boolean;
}

const AuthContext = createContext<AuthContextValue | null>(null);

function getStoredUser(): User | null {
  try {
    const raw = localStorage.getItem('lt_user');
    return raw ? JSON.parse(raw) : null;
  } catch {
    return null;
  }
}

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(getStoredUser);

  const persistUser = useCallback((u: User) => {
    localStorage.setItem('lt_user', JSON.stringify(u));
    localStorage.setItem('lt_token', u.token);
    setUser(u);
  }, []);

  const login = useCallback(async (email: string, password: string) => {
    const u = await authApi.login(email, password);
    persistUser(u);
  }, [persistUser]);

  const register = useCallback(async (data: Parameters<typeof authApi.register>[0]) => {
    const u = await authApi.register(data);
    persistUser(u);
  }, [persistUser]);

  const logout = useCallback(() => {
    localStorage.removeItem('lt_user');
    localStorage.removeItem('lt_token');
    setUser(null);
  }, []);

  return createElement(AuthContext.Provider,
    { value: { user, login, register, logout, isAuthenticated: !!user } },
    children
  );
}

export function useAuth(): AuthContextValue {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used within AuthProvider');
  return ctx;
}
