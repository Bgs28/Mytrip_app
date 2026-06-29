<?php
namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Train;
use Illuminate\Http\Request;

class TrainController extends Controller
{
    public function index(){
        $trains = Train::latest()->paginate(10);
        return view('admin.train.index', compact('trains'));
    }

    public function create(){
        return view('admin.train.create');
    }

    public function store(Request $request){
        $request->validate([
            'train_name' => 'required|string|max:255',
            'from' => 'required|string|max:255',
            'destination' => 'required|string|max:255',
            'departure_time' => 'required',
            'arrival_time' => 'required',
            'price' => 'required|integer|min:0',
            'seat' => 'required|integer|min:0',
        ]);

        Train::create($request->all());

        return redirect()->route('admin.trains.index')->with('success', 'Data Kereta berhasil ditambahkan.');
    }

    public function edit($id){
        $train = Train::findOrFail($id);
        return view('admin.train.edit', compact('train'));
    }

    public function update(Request $request, $id){
        $train = Train::findOrFail($id);

    $request->validate([
            'train_name' => 'required|string|max:255',
            'from' => 'required|string|max:255',
            'destination' => 'required|string|max:255',
            'departure_time' => 'required',
            'arrival_time' => 'required',
            'price' => 'required|integer|min:0',
            'seat' => 'required|integer|min:0',
    ]);

    $train->update($request->all());

    return redirect()->route('admin.trains.index')->with('success', 'Data Kereta berhasil diperbarui.');
    }

    public function destroy($id){
        $train = Train::findOrFail($id);
        $train->delete();

        return redirect()->route('admin.trains.index')->with('success', 'Data Kereta berhasil dihapus.');
    }
}
