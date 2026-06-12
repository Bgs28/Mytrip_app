<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Flight;
use Illuminate\Http\Request;

class FlightController extends Controller
{
    public function index(){
        return response()->json([
            'data'=>Flight::all()
        ]);
    }

    public function show($id){
        return response()->json([
            'data'=>Flight::findOrFail($id)
        ]);
    }
}
