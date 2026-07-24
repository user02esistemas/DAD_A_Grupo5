/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Interface.java to edit this template
 */
package Interfaces;

import entidades.Empleados;
import java.rmi.Remote;
import java.rmi.RemoteException;
import java.util.List;

public interface IGestionEmpleadosRemoto extends Remote {
    
    List<Empleados> listarEmpleados() throws RemoteException;
    
    Empleados buscarEmpleadoPorId(int idUsuario) throws RemoteException;
    
    boolean registrarEmpleado(Empleados empleado) throws RemoteException;
    
    boolean actualizarEmpleado(Empleados empleado) throws RemoteException;
    
    boolean eliminarEmpleado(int idUsuario) throws RemoteException;
    
}
