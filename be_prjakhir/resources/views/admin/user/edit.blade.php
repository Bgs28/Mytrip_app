@extends('admin.layouts.admin')

@section('title', 'Edit User')

@section('content')
<div class="max-w-3xl bg-white rounded-xl shadow-sm border border-gray-100 p-6">
    <div class="mb-6">
        <h1 class="text-xl font-bold text-gray-900">Edit Data User</h1>
        <p class="text-sm text-gray-500 mt-1">Mengubah data profil milik pengguna: <span class="font-semibold text-gray-800">{{ $user->name }}</span></p>
    </div>

    @if ($errors->any())
        <div class="mb-6 p-4 bg-rose-50 border border-rose-200 text-rose-800 rounded-lg text-sm">
            <ul class="list-disc list-inside space-y-1">
                @foreach ($errors->all() as $error)
                    <li>{{ $error }}</li>
                @endforeach
            </ul>
        </div>
    @endif

    <form action="{{ route('admin.users.update', $user->id) }}" method="POST" enctype="multipart/form-data" class="space-y-5">
        @csrf
        @method('PUT')
        
        <div>
            <label class="block text-sm font-medium text-gray-700 mb-1.5">Nama Lengkap</label>
            <input type="text" name="name" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition text-sm" value="{{ old('name', $user->name) }}" required>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1.5">Email</label>
                <input type="email" name="email" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition text-sm" value="{{ old('email', $user->email) }}" required>
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1.5">No. Telepon / HP</label>
                <input type="text" name="phone" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition text-sm" value="{{ old('phone', $user->phone) }}">
            </div>
        </div>

        <div>
            <label class="block text-sm font-medium text-gray-700 mb-1.5">Role Akses</label>
            <select name="role" class="w-full px-3 py-2 border border-gray-300 rounded-lg bg-white focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition text-sm" required>
                <option value="user" {{ old('role', $user->role) == 'user' ? 'selected' : '' }}>User (Flutter Mobile)</option>
                <option value="admin" {{ old('role', $user->role) == 'admin' ? 'selected' : '' }}>Admin (Web Panel)</option>
            </select>
        </div>

        <div class="p-4 bg-gray-50 border border-gray-200 rounded-lg space-y-4">
            <span class="block text-xs font-semibold text-gray-500 uppercase tracking-wider">Ubah Password (Opsional)</span>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                    <label class="block text-xs font-medium text-gray-600 mb-1">Password Baru</label>
                    <input type="password" name="password" class="w-full px-3 py-1.5 border border-gray-300 rounded-lg bg-white focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition text-sm" placeholder="Kosongkan jika tidak diubah">
                </div>
                <div>
                    <label class="block text-xs font-medium text-gray-600 mb-1">Konfirmasi Password Baru</label>
                    <input type="password" name="password_confirmation" class="w-full px-3 py-1.5 border border-gray-300 rounded-lg bg-white focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition text-sm" placeholder="Ulangi password baru">
                </div>
            </div>
        </div>

        <div>
            <label class="block text-sm font-medium text-gray-700 mb-1.5">Avatar / Foto Profil</label>
            <div class="flex items-center gap-4 mb-3">
                @if($user->avatar)
                    <img src="{{ asset('storage/' . $user->avatar) }}" class="h-16 w-16 rounded-lg object-cover border border-gray-200 shadow-sm" alt="Avatar saat ini">
                @else
                    <div class="h-16 w-16 rounded-lg bg-gray-100 flex items-center justify-center border border-gray-200 text-gray-400 text-xs text-center font-medium px-1">
                        Belum ada avatar
                    </div>
                @endif
                <div class="flex-1">
                    <input type="file" name="avatar" class="w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100 border border-gray-300 rounded-lg p-1">
                </div>
            </div>
        </div>

        <div class="flex items-center gap-3 pt-4 border-t border-gray-100">
            <button type="submit" class="bg-blue-600 hover:bg-blue-700 text-white font-medium px-5 py-2 rounded-lg transition text-sm shadow-sm">
                Perbarui Data
            </button>
            <a href="{{ route('admin.users.index') }}" class="bg-gray-100 hover:bg-gray-200 text-gray-700 font-medium px-5 py-2 rounded-lg transition text-sm">
                Kembali
            </a>
        </div>
    </form>
</div>
@endsection