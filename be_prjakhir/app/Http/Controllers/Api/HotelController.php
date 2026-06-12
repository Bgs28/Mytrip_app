<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Hotel;
use Illuminate\Http\Request;

class HotelController extends Controller
{
    public function index(){
        return response()->json([
            'data'=> Hotel::all()
        ]);
    }

    public function show($id){
        return response()->json([
            'data'=>Hotel::findOrFail($id)
        ]);
    }
}
