import { describe, it, expect, vi, beforeEach } from 'vitest';
import { useAuthStore } from './authStore';

// Mock the supabase client
const mockSignInWithPassword = vi.fn();
const mockSignUp = vi.fn();
const mockSignInWithOAuth = vi.fn();
const mockSignOut = vi.fn();
const mockResetPasswordForEmail = vi.fn();
const mockGetSession = vi.fn();
const mockOnAuthStateChange = vi.fn();

vi.mock('@/lib/supabase', () => ({
  supabase: {
    auth: {
      signInWithPassword: (...args: unknown[]) => mockSignInWithPassword(...args),
      signUp: (...args: unknown[]) => mockSignUp(...args),
      signInWithOAuth: (...args: unknown[]) => mockSignInWithOAuth(...args),
      signOut: (...args: unknown[]) => mockSignOut(...args),
      resetPasswordForEmail: (...args: unknown[]) => mockResetPasswordForEmail(...args),
      getSession: (...args: unknown[]) => mockGetSession(...args),
      onAuthStateChange: (...args: unknown[]) => mockOnAuthStateChange(...args),
    },
  },
}));

describe('authStore', () => {
  beforeEach(() => {
    // Reset store state between tests
    useAuthStore.setState({
      user: null,
      session: null,
      loading: true,
      error: null,
      sessionExpired: false,
    });
    vi.clearAllMocks();
  });

  describe('initial state', () => {
    it('has null user and session', () => {
      const state = useAuthStore.getState();
      expect(state.user).toBeNull();
      expect(state.session).toBeNull();
    });

    it('starts with loading=true', () => {
      const state = useAuthStore.getState();
      expect(state.loading).toBe(true);
    });

    it('has no error', () => {
      const state = useAuthStore.getState();
      expect(state.error).toBeNull();
    });

    it('sessionExpired is false', () => {
      const state = useAuthStore.getState();
      expect(state.sessionExpired).toBe(false);
    });
  });

  describe('signInWithEmail', () => {
    it('updates state on successful sign in', async () => {
      const mockUser = { id: 'u1', email: 'test@example.com' };
      const mockSession = { access_token: 'token123', user: mockUser };

      mockSignInWithPassword.mockResolvedValueOnce({
        data: { user: mockUser, session: mockSession },
        error: null,
      });

      await useAuthStore.getState().signInWithEmail('test@example.com', 'password');

      const state = useAuthStore.getState();
      expect(state.user).toEqual(mockUser);
      expect(state.session).toEqual(mockSession);
      expect(state.loading).toBe(false);
      expect(state.error).toBeNull();
    });

    it('sets loading=true during sign in', async () => {
      let loadingDuringCall = false;
      mockSignInWithPassword.mockImplementation(() => {
        loadingDuringCall = useAuthStore.getState().loading;
        return Promise.resolve({
          data: { user: { id: 'u1' }, session: { access_token: 't' } },
          error: null,
        });
      });

      await useAuthStore.getState().signInWithEmail('test@example.com', 'password');
      expect(loadingDuringCall).toBe(true);
    });

    it('sets error on failed sign in', async () => {
      mockSignInWithPassword.mockResolvedValueOnce({
        data: { user: null, session: null },
        error: { message: 'Invalid credentials' },
      });

      await expect(
        useAuthStore.getState().signInWithEmail('test@example.com', 'wrong'),
      ).rejects.toBeDefined();

      const state = useAuthStore.getState();
      expect(state.error).toBe('Invalid credentials');
      expect(state.loading).toBe(false);
      expect(state.user).toBeNull();
    });
  });

  describe('signUpWithEmail', () => {
    it('updates state on successful sign up', async () => {
      const mockUser = { id: 'u1', email: 'new@example.com' };
      const mockSession = { access_token: 'token123', user: mockUser };

      mockSignUp.mockResolvedValueOnce({
        data: { user: mockUser, session: mockSession },
        error: null,
      });

      await useAuthStore.getState().signUpWithEmail('new@example.com', 'password');

      const state = useAuthStore.getState();
      expect(state.user).toEqual(mockUser);
      expect(state.session).toEqual(mockSession);
      expect(state.loading).toBe(false);
    });

    it('sets error on failed sign up', async () => {
      mockSignUp.mockResolvedValueOnce({
        data: { user: null, session: null },
        error: { message: 'Email already exists' },
      });

      await expect(
        useAuthStore.getState().signUpWithEmail('existing@example.com', 'password'),
      ).rejects.toBeDefined();

      expect(useAuthStore.getState().error).toBe('Email already exists');
    });
  });

  describe('signOut', () => {
    it('clears user, session, and sessionExpired on sign out', async () => {
      // Set up a signed-in state
      useAuthStore.setState({
        user: { id: 'u1' } as any,
        session: { access_token: 't' } as any,
        loading: false,
        error: null,
        sessionExpired: true,
      });

      mockSignOut.mockResolvedValueOnce({ error: null });

      await useAuthStore.getState().signOut();

      const state = useAuthStore.getState();
      expect(state.user).toBeNull();
      expect(state.session).toBeNull();
      expect(state.loading).toBe(false);
      expect(state.error).toBeNull();
      expect(state.sessionExpired).toBe(false);
    });

    it('sets error on failed sign out', async () => {
      useAuthStore.setState({
        user: { id: 'u1' } as any,
        session: { access_token: 't' } as any,
        loading: false,
      });

      mockSignOut.mockResolvedValueOnce({
        error: { message: 'Network error' },
      });

      await expect(useAuthStore.getState().signOut()).rejects.toBeDefined();

      expect(useAuthStore.getState().error).toBe('Network error');
      expect(useAuthStore.getState().loading).toBe(false);
    });
  });

  describe('initialize', () => {
    it('sets user and session from existing session', async () => {
      const mockUser = { id: 'u1' };
      const mockSession = { access_token: 't', user: mockUser };

      mockGetSession.mockResolvedValueOnce({
        data: { session: mockSession },
      });

      mockOnAuthStateChange.mockReturnValueOnce({
        data: { subscription: { unsubscribe: vi.fn() } },
      });

      await useAuthStore.getState().initialize();

      const state = useAuthStore.getState();
      expect(state.user).toEqual(mockUser);
      expect(state.session).toEqual(mockSession);
      expect(state.loading).toBe(false);
    });

    it('sets loading=false when no existing session', async () => {
      mockGetSession.mockResolvedValueOnce({
        data: { session: null },
      });

      mockOnAuthStateChange.mockReturnValueOnce({
        data: { subscription: { unsubscribe: vi.fn() } },
      });

      await useAuthStore.getState().initialize();

      const state = useAuthStore.getState();
      expect(state.user).toBeNull();
      expect(state.session).toBeNull();
      expect(state.loading).toBe(false);
    });

    it('returns cleanup function that unsubscribes', async () => {
      const unsubscribe = vi.fn();

      mockGetSession.mockResolvedValueOnce({
        data: { session: null },
      });

      mockOnAuthStateChange.mockReturnValueOnce({
        data: { subscription: { unsubscribe } },
      });

      const cleanup = await useAuthStore.getState().initialize();
      cleanup();

      expect(unsubscribe).toHaveBeenCalledTimes(1);
    });
  });

  describe('clearError', () => {
    it('clears the error state', () => {
      useAuthStore.setState({ error: 'Some error' });
      expect(useAuthStore.getState().error).toBe('Some error');

      useAuthStore.getState().clearError();
      expect(useAuthStore.getState().error).toBeNull();
    });
  });

  describe('resetPassword', () => {
    it('calls resetPasswordForEmail', async () => {
      mockResetPasswordForEmail.mockResolvedValueOnce({ error: null });

      await useAuthStore.getState().resetPassword('test@example.com');

      expect(mockResetPasswordForEmail).toHaveBeenCalledWith(
        'test@example.com',
        expect.objectContaining({ redirectTo: expect.stringContaining('/login') }),
      );
    });

    it('sets error on failure', async () => {
      mockResetPasswordForEmail.mockResolvedValueOnce({
        error: { message: 'User not found' },
      });

      await expect(
        useAuthStore.getState().resetPassword('unknown@example.com'),
      ).rejects.toBeDefined();

      expect(useAuthStore.getState().error).toBe('User not found');
    });
  });
});
