# Profile Data Saving - Fixes Applied

## Problem
Only images were being uploaded to storage, but profile data was not being saved to the `profiles` table.

## Root Cause
The `updateProfile` method was trying to update a profile that might not exist yet, causing silent failures.

## Fixes Applied

### 1. ProfileService - Enhanced updateProfile Method
**File:** `lib/data/service/profile_service.dart`

**Changes:**
- Added check to see if profile exists before updating
- If profile doesn't exist, creates it first using upsert
- Added comprehensive debug logging
- Added `.select()` to update query to verify success

**Before:**
```dart
await supabase.from('profiles').update(updates).eq('id', userId);
```

**After:**
```dart
// Check if profile exists first
final existing = await getProfile(userId);
if (existing == null) {
  // Create profile if it doesn't exist
  await upsertProfile(ProfileModel(id: userId, showOnboarding: true));
}
// Then update
await supabase.from('profiles').update(updates).eq('id', userId).select();
```

### 2. OnboardingController - Added Debug Logging
**File:** `lib/view/controllers/onboarding_controller/OnboardingScreen/onboarding_screen_controller.dart`

**Changes:**
- Added print statements for every field being saved
- Added logging for user authentication check
- Added logging for save success/failure
- Added detailed logging for image upload process

### 3. StorageService - Added Debug Logging
**File:** `lib/data/service/storage_service.dart`

**Changes:**
- Added file existence check before upload
- Added logging for upload progress
- Added logging for public URL generation
- Added error logging

## How to Test

### 1. Run the app in debug mode
```bash
flutter run
```

### 2. Watch console output
You should see logs like:
```
OnboardingController: Saving profile data for user: abc123
OnboardingController: Adding dob: 1990-01-01
OnboardingController: Adding gender: Male
ProfileService: Updating profile for user: abc123
ProfileService: Profile updated successfully
```

### 3. Check Supabase Database
After each onboarding step, run:
```sql
SELECT * FROM public.profiles WHERE id = '<your_user_id>';
```

### 4. Verify Data
- After Basics: dob, gender, ethnicity, orientation, languages should be saved
- After Photo: photo_url should be populated
- After About: bio, children, relationship, dietary, religion should be saved
- After Interests: interests and passion_topics should be saved
- After Final: show_onboarding should be false

## What to Look For

### Success Indicators:
✅ Console shows "Profile updated successfully"
✅ Database query shows data in respective columns
✅ No error messages in console
✅ Image appears in Storage bucket
✅ photo_url field is populated in database

### Failure Indicators:
❌ Console shows "Error updating profile"
❌ Database query shows NULL values
❌ Console shows "Profile does not exist" repeatedly
❌ No image in Storage bucket
❌ photo_url is NULL

## If Data Still Not Saving

### Check 1: Verify Profile Exists
```sql
SELECT id, name, email FROM public.profiles WHERE id = '<user_id>';
```
If no results, profile wasn't created during signup.

### Check 2: Check RLS Policies
```sql
SELECT * FROM pg_policies WHERE tablename = 'profiles';
```
Should have policies for SELECT, INSERT, and UPDATE.

### Check 3: Test Manual Update
```sql
UPDATE public.profiles 
SET dob = '1990-01-01', gender = 'Male'
WHERE id = '<user_id>';
```
If this fails, it's a permissions issue.

### Check 4: Verify User is Authenticated
Add this to OnboardingController:
```dart
print('Current user: ${AuthService.currentUser?.id}');
print('Is logged in: ${AuthService.isLoggedIn}');
```

## Additional Debugging

### Enable Supabase Logging
In `main.dart`, add:
```dart
await Supabase.initialize(
  url: 'your-url',
  anonKey: 'your-key',
  debug: true, // Add this
);
```

### Check Network Tab
In Chrome DevTools (if running on web):
1. Open Network tab
2. Filter by "profiles"
3. Check request/response for UPDATE calls
4. Look for 200 (success) or 403/500 (error)

## Files Modified

1. ✅ `lib/data/service/profile_service.dart` - Fixed updateProfile logic
2. ✅ `lib/view/controllers/onboarding_controller/OnboardingScreen/onboarding_screen_controller.dart` - Added logging
3. ✅ `lib/data/service/storage_service.dart` - Added logging
4. ✅ `lib/view/screens/onboardingscreens/pages/photo_page.dart` - Added Next button

## Next Steps

1. Run the app
2. Complete onboarding
3. Check console logs
4. Verify data in Supabase
5. If issues persist, share console logs and SQL query results

## Testing Checklist

- [ ] Console shows "Saving profile data" after each step
- [ ] Console shows "Profile updated successfully"
- [ ] Database shows data after Basics step
- [ ] Database shows photo_url after Photo step
- [ ] Database shows bio/children/etc after About step
- [ ] Database shows interests/passions after Interests step
- [ ] Database shows show_onboarding=false after Final step
- [ ] Image visible in Storage bucket
- [ ] Logout and login shows profile data (not onboarding)

## Support

Refer to:
- `TESTING_GUIDE.md` - Detailed testing instructions
- `TROUBLESHOOTING.md` - Common issues and solutions
- Console logs - For debugging specific issues
