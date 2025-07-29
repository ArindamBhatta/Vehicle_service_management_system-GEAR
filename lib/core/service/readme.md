> AuthService deals with authentication (signing in/out, checking session, etc.), 

> while UserService deals with user profile data stored in your own database.

> Returns	User (from supabase.auth)
> 	AppUser (your custom model)

> Fields Available	id, email, created_at, maybe user_metadata	
> firstName, lastName, role, shopIds, etc.

> Why both are necessary
1. AuthService.currentUser returns limited info — mostly what’s needed for session handling.

final user = _client.auth.currentUser;
print(user?.email); // ✅
print(user?.id);    // ✅
print(user?.role);  // ❌ (not part of auth data)
2. UserService returns more detailed user data, which is not available in AuthService. This includes fields lik

After sign-up:

1. AuthService.signUp() creates the auth user.

2. UserService.createUserProfileIfNotExists() creates their app profile in your DB.



AuthService = checking your ID at the entrance (are you who you say you are?)

UserService = accessing your bank account profile, balance, account settings, etc.


