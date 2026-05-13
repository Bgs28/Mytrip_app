<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class UserController extends Controller
{
    public function index()
    {
        return response()->json(User::all());
    }

    // Tambah User
    public function store(Request $request) {
        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
        ]);
        return response()->json(['message' => 'User berhasil ditambah!', 'data' => $user]);
    }

    // Hapus User
    public function destroy($id) {
        $user = User::find($id);
        if(!$user) return response()->json(['message' => 'User tidak ketemu'], 404);

        $user->delete();
        return response()->json(['message' => 'User berhasil dihapus']);
    }

    public function update(Request $request, $id)
{
    $user = User::find($id);

    if (!$user) {
        return response()->json(['message' => 'User tidak ditemukan'], 404);
    }

    $request->validate([
        'name' => 'required',
        'email' => 'required|email',
        'password' => 'nullable|min:6',
    ]);

    $user->name = $request->name;
    $user->email = $request->email;

    if ($request->password) {
        $user->password = Hash::make($request->password);
    }

    $user->save();

    return response()->json([
        'message' => 'User berhasil diupdate',
        'data' => $user
    ]);
}

public function login(Request $request) {
    $user = User::where('email', $request->email)->first();

    if (!$user) {
    return response()->json([
        'success' => false,
        'message' => 'Email tidak ditemukan'
    ], 401);
}

if (!Hash::check($request->password, $user->password)) {
    return response()->json([
        'success' => false,
        'message' => 'Password salah'
    ], 401);
}

return response()->json([
    'success' => true,
    'message' => 'Login berhasil',
    'data' => $user
]);
}
}

    