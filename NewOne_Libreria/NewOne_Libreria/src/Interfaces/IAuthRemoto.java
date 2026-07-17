/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Interface.java to edit this template
 */
package Interfaces;

import entidades.Clientes;
import entidades.Empleados;
import java.rmi.Remote;
import java.rmi.RemoteException;

/**
 *
 * @author Acer
 */

public interface IAuthRemoto extends Remote {
    Clientes loginCliente(String email, String password) throws RemoteException;
    Empleados loginAdmin(String codigo, String password) throws RemoteException;
}