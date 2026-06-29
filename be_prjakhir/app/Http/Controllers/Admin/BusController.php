<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Bus;
use Illuminate\Http\Request;

class BusController extends Controller{
    public function index(){
        $buses = Bus::latest()->paginate(10);
        return view('admin.bus.index', compact('buses'));
    }

    public function create(){
        return view('admin.bus.create');
    }

    public function store(Request $request){
        $request->validate([
            'bus_name' => 'required|string|max:255',
            'from' => 'required|string|max:255',
            'destination' => 'required|string|max:255',
            'departure_time' => 'required',
            'price' => 'required|integer|min:0',
            'seat' => 'required|integer|min:0',
        ]);
        
        Bus::create($request->all());
        return redirect()->route('admin.buses.index')->with('success', "Armada Bus berhasil dditambahkan.");
        }
        
        public function edit($id){
            $bus = Bus::findOrFail($id);
            return view('admin.bus.edit', compact('bus'));
        }
            
        public function update(Request $request, $id){
            $bus = Bus::findOrFail($id);

            $request->validate([
                'bus_name' => 'required|string|max:255',
                'from' => 'required|string|max:255',
                'destination' => 'required|string|max:255',
                'departure_time' => 'required',
                'price' => 'required|integer|min:0',
                'seat' => 'required|integer|min:0',
            ]);

            $bus->update($request->all());
            return redirect()->route('admin.buses.index')->with('success', 'Data bus berhasil diperbarui.');
        }

        public function destroy($id){
            $bus = Bus::findOrFail($id);
            $bus->delete();

            return redirect()->route('admin.buses.index')->with('success', "Armada Bus berhasil dihapus.");
        }

}