@extends('admin.layouts.admin')

@section('title', 'Edit Hotel')

@section('content')
<div class="max-w-3xl bg-white rounded-xl shadow-sm border border-gray-100 p-6">
    <div class="mb-6">
        <h1 class="text-xl font-bold text-gray-900">Edit Data Hotel</h1>
        <p class="text-sm text-gray-500 mt-1">Mengubah informasi hotel: <span class="font-semibold text-gray-800">{{ $hotel->name }}</span></p>
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

    <form action="{{ route('admin.hotels.update', $hotel->id) }}" method="POST" enctype="multipart/form-data" class="space-y-5">
        @csrf
        @method('PUT')
        
        <div>
            <label class="block text-sm font-medium text-gray-700 mb-1.5">Nama Hotel</label>
            <input type="text" name="name" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 text-sm" value="{{ old('name', $hotel->name) }}" required>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1.5">Lokasi / Kota</label>
                <input type="text" name="location" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 text-sm" value="{{ old('location', $hotel->location) }}" required>
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1.5">Harga Per Malam (Rp)</label>
                <input type="number" name="price" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 text-sm" value="{{ old('price', $hotel->price) }}" required>
            </div>
        </div>

        <div>
            <label class="block text-sm font-medium text-gray-700 mb-1.5">Rating Hotel</label>
            <input type="number" step="0.1" min="0" max="5" name="rating" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 text-sm" value="{{ old('rating', $hotel->rating) }}" required>
        </div>

        <div>
            <label class="block text-sm font-medium text-gray-700 mb-1.5">Deskripsi Hotel</label>
            <textarea name="description" rows="4" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 text-sm" placeholder="Tulis detail atau fasilitas hotel...">{{ old('description', $hotel->description) }}</textarea>
        </div>

        <div>
            <label class="block text-sm font-medium text-gray-700 mb-1.5">Foto Hotel</label>
            <div class="flex items-center gap-4 mb-3">
                @if($hotel->image)
                    <img src="{{ asset('storage/' . $hotel->image) }}" class="h-20 w-32 rounded-lg object-cover border border-gray-200 shadow-sm" alt="Foto saat ini">
                @else
                    <div class="h-20 w-32 rounded-lg bg-gray-100 flex items-center justify-center border border-gray-200 text-gray-400 text-xs text-center font-medium px-1">
                        Belum ada foto
                    </div>
                @endif
                <div class="flex-1">
                    <input type="file" name="image" class="w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100 border border-gray-300 rounded-lg p-1">
                    <p class="text-xs text-gray-400 mt-1">Kosongkan jika tidak ingin mengubah foto hotel</p>
                </div>
            </div>
        </div>

        <div class="flex items-center gap-3 pt-4 border-t border-gray-100">
            <button type="submit" class="bg-blue-600 hover:bg-blue-700 text-white font-medium px-5 py-2 rounded-lg transition text-sm shadow-sm">
                Perbarui Hotel
            </button>
            <a href="{{ route('admin.hotels.index') }}" class="bg-gray-100 hover:bg-gray-200 text-gray-700 font-medium px-5 py-2 rounded-lg transition text-sm">
                Kembali
            </a>
        </div>
    </form>
</div>
@endsection