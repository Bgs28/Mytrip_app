<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AuthController extends Controller
{
    public function loginPage(){
        return view('admin.login');
    }

    public function login(Request $request){

    $credentials = $request->validate([
        'email'=> 'required|email',
        'password'=>'required'
    ]);

    if(Auth::attempt($credentials))
    {
        if(Auth::user()->role !== 'admin')
        {
            Auth::logout();

            return back()->with(
                'error',
                'Bukan akun Admin'
            );
        }
        return redirect('/admin/dashboard');
    }

    return back()->with(
        'error',
        'Email atau Password salah!!'
    );
    }

    public function logout()
    {
        Auth::logout();

        return redirect('/admin/login');
    }


}
