/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Interface.java to edit this template
 */
package Interfaces;

import entidades.Citas;
import entidades.Servicios;
import java.rmi.Remote;
import java.rmi.RemoteException;
import java.util.List;

/**
 *
 * @author Acer
 */

public interface IGestionServiciosRemoto extends Remote {
    List<Servicios> listarServiciosDisponibles() throws RemoteException;
    boolean agendarCita(Citas cita) throws RemoteException;
    List<Citas> listarCitasPendientes() throws RemoteException;
}