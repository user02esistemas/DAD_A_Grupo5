/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Interface.java to edit this template
 */
package Interfaces;

import entidades.Clientes;
import java.rmi.Remote;
import java.rmi.RemoteException;
import java.util.List;

public interface IGestionClientesRemoto extends Remote {
    
    List<Clientes> listarClientes() throws RemoteException;
    
    Clientes buscarClientePorId(int idCliente) throws RemoteException;
    
    boolean registrarCliente(Clientes cliente) throws RemoteException;
    
    boolean actualizarCliente(Clientes cliente) throws RemoteException;
    
    boolean eliminarCliente(int idCliente) throws RemoteException;
    
}