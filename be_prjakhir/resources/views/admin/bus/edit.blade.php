@extends('admin.layouts.admin')

@section('title', 'Edit Bus')

@section('content')
<div class="max-w-3xl bg-white rounded-xl shadow-sm border border-gray-100 p-6">
    <h1 class="text-xl font-bold text-gray-900 mb-6">Edit Jadwal Perjalanan Bus</h1>

    <form action="{{ route('admin.buses.update', $bus->id) }}" method="POST" class="space-y-5">
        @csrf
        @method('PUT')
        
        <div>
            <label class="block text-sm font-medium text-gray-700 mb-1.5">Nama Perusahaan Bus (PO / Fleet)</label>
            <input type="text" name="bus_name" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 text-sm" value="{{ old('bus_name', $bus->bus_name) }}" required>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1.5">Terminal Asal / Kota Asal</label>
                <input type="text" name="from" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 text-sm" value="{{ old('from', $bus->from) }}" required>
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1.5">Terminal Tujuan / Kota Tujuan</label>
                <input type="text" name="destination" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 text-sm" value="{{ old('destination', $bus->destination) }}" required>
            </div>
        </div>

        <div>
            <label class="block text-sm font-medium text-gray-700 mb-1.5">Jam Keberangkatan</label>
            <input type="time" name="departure_time" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 text-sm" value="{{ old('departure_time', \Carbon\Carbon::parse($bus->departure_time)->format('H:i')) }}" required>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1.5">Harga Tiket (Rp)</label>
                <input type="number" name="price" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 text-sm" value="{{ old('price', $bus->price) }}" required>
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1.5">Total Kursi Penumpang</label>
                <input type="number" name="seat" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 text-sm" value="{{ old('seat', $bus->seat) }}" required>
            </div>
        </div>

        <div class="flex items-center gap-3 pt-4 border-t">
            <button type="submit" class="bg-blue-600 hover:bg-blue-700 text-white font-medium px-5 py-2 rounded-lg text-sm">Perbarui Rute Bus</button>
            <a href="{{ route('admin.buses.index') }}" class="bg-gray-100 hover:bg-gray-200 text-gray-700 font-medium px-5 py-2 rounded-lg text-sm">Kembali</a>
        </div>
    </form>
</div>
@endsection