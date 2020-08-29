using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class Menu : MonoBehaviour {

    public void StartFirstLevel()
    {
        SceneManager.LoadScene(2);
    }

    public void LoadMainMenu()
    {
        SceneManager.LoadScene(1);
    }
}
