/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Interface.java to edit this template
 */
package Interfaces;

import entidades.Productos;
import java.rmi.Remote;
import java.rmi.RemoteException;
import java.util.List;

/**
 *
 * @author Acer
 */

public interface IGestionProductosRemoto extends Remote {
    List<Productos> listarProductosActivos() throws RemoteException;
    List<Productos> listarTodosProductos() throws RemoteException;
    Productos buscarProductoPorId(int idProducto) throws RemoteException;
    boolean registrarProducto(Productos producto) throws RemoteException;
    boolean actualizarProducto(Productos producto) throws RemoteException;
    boolean eliminarProducto(int idProducto) throws RemoteException;
}
